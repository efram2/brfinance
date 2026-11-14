#' Download SGS series from Brazilian Central Bank
#'
#' Internal helper function to download time series data from BCB SGS API.
#' Requests spanning more than 10 years are automatically split into
#' consecutive 9-year windows and stitched back together, since the BCB
#' API rejects date ranges longer than 10 years in a single call.
#'
#' This function never signals an error because of the web resource
#' (no connection, timeout, HTTP error, HTML page instead of JSON, JSON with an
#' unexpected structure, ...). Instead it prints an informative message that
#' names the cause and returns an empty data.frame with columns `date` and
#' `value`. Invalid user input (e.g. a malformed date) is still an error.
#'
#' @param series_id Numeric. SGS series ID.
#' @param start_date Start date (YYYY, YYYY-MM, or YYYY-MM-DD format).
#' @param end_date End date (YYYY, YYYY-MM, YYYY-MM-DD format, or NULL for current date).
#'
#' @return A data.frame with columns 'date' (Date) and 'value' (numeric).
#' @keywords internal
#'
#' @examples
#' \donttest{
#' # Example: download SELIC series (ID 11)
#' df <- brfinance:::.get_sgs_series(11, "2020", "2021")
#'
#' head(df)
#' tail(df)
#' }
.get_sgs_series <- function(series_id,
                            start_date = NULL,
                            end_date = NULL) {

  start_date <- .normalize_date(start_date, is_start = TRUE)
  end_date   <- .normalize_date(end_date, is_start = FALSE)

  # 9 years (not 10) keeps a safe margin from the API's 10-year limit
  janelas <- .split_date_windows(start_date, end_date, max_years = 9)

  partes <- vector("list", nrow(janelas))
  notas  <- character()

  for (i in seq_len(nrow(janelas))) {
    res <- .download_sgs_window(series_id, janelas$start[i], janelas$end[i])

    # A real failure: the reason was already reported with message().
    # Returning partial data would silently hide missing years.
    if (!isTRUE(res$ok)) {
      return(.empty_sgs())
    }

    partes[[i]] <- res$data
    if (!is.null(res$note)) notas <- c(notas, res$note)
  }

  df <- do.call(rbind, partes)

  # Windows are inclusive on both ends: drop duplicated boundary dates
  df <- df[!duplicated(df$date), , drop = FALSE]
  df <- df[order(df$date), , drop = FALSE]
  rownames(df) <- NULL

  if (nrow(df) == 0) {
    message(sprintf(
      "Series %s (%s to %s): no data available for the requested period.%s Returning an empty data frame.",
      series_id,
      format(start_date, "%Y-%m-%d"),
      format(end_date, "%Y-%m-%d"),
      if (length(notas) > 0) paste0(" ", notas[1]) else ""
    ))
    return(.empty_sgs())
  }

  df
}

# Empty result with the standard structure
.empty_sgs <- function() {
  data.frame(date = as.Date(character()), value = numeric())
}

# Short, single-line excerpt of a response body for use in messages
.snippet <- function(txt, n = 150) {
  if (is.null(txt) || length(txt) != 1 || is.na(txt)) return("")
  txt <- tryCatch(
    {
      txt <- iconv(txt, "UTF-8", "UTF-8", sub = "")
      txt <- gsub("[[:space:]]+", " ", txt)
      if (nchar(txt) > n) paste0(substr(txt, 1, n), "...") else txt
    },
    error = function(e) ""
  )
  txt
}

# -------------------------------------------------------------------
# Split a date range into consecutive windows of at most `max_years`
# -------------------------------------------------------------------

#' @keywords internal
#' @noRd
.split_date_windows <- function(start_date, end_date, max_years = 9) {

  if (start_date > end_date) {
    stop("'start_date' must be earlier than or equal to 'end_date'.", call. = FALSE)
  }

  starts <- as.Date(character())
  ends   <- as.Date(character())
  cursor <- start_date

  # repeat (not while): a request for a single day must yield one window
  repeat {
    janela_fim <- min(
      seq(cursor, by = paste(max_years, "years"), length.out = 2)[2] - 1,
      end_date
    )

    starts <- c(starts, cursor)
    ends   <- c(ends, janela_fim)

    if (janela_fim >= end_date) break

    cursor <- janela_fim + 1
  }

  data.frame(start = starts, end = ends)
}

# -------------------------------------------------------------------
# Download a single (<= 10 year) window from the BCB SGS API
# -------------------------------------------------------------------
# Returns list(ok, data, note):
#   ok = FALSE : real failure, message() already printed
#   ok = TRUE  : request worked; `data` may be empty (series has no
#                observations in this window), `note` explains why

#' @keywords internal
#' @noRd
.download_sgs_window <- function(series_id, start_date, end_date) {

  label <- sprintf(
    "Series %s (%s to %s)",
    series_id, format(start_date, "%Y-%m-%d"), format(end_date, "%Y-%m-%d")
  )

  fail <- function(reason) {
    message(label, ": ", reason, " Returning an empty data frame.")
    list(ok = FALSE, data = .empty_sgs(), note = NULL)
  }

  no_data <- function(note) {
    list(ok = TRUE, data = .empty_sgs(), note = note)
  }

  url <- sprintf(
    "https://api.bcb.gov.br/dados/serie/bcdata.sgs.%s/dados?formato=json&dataInicial=%s&dataFinal=%s",
    series_id,
    format(start_date, "%d/%m/%Y"),
    format(end_date, "%d/%m/%Y")
  )

  max_tries <- getOption("brfinance.max_tries", 3L)

  # 1. Request ---------------------------------------------------------
  req <- httr2::request(url)
  req <- httr2::req_user_agent(req, "brfinance R package (https://github.com/efram2/brfinance)")
  req <- httr2::req_headers(req, Accept = "application/json")
  req <- httr2::req_timeout(req, 20)
  req <- httr2::req_error(req, is_error = function(resp) FALSE)  # we handle status codes ourselves
  if (max_tries >= 2) {
    req <- httr2::req_retry(
      req,
      max_tries = max_tries,
      is_transient = function(resp) httr2::resp_status(resp) %in% c(429L, 500L, 502L, 503L, 504L),
      backoff = function(i) 2
    )
  }

  resp <- tryCatch(httr2::req_perform(req), error = function(e) e)

  if (inherits(resp, "error")) {
    detail <- conditionMessage(resp)
    if (!is.null(resp$parent)) detail <- paste(detail, conditionMessage(resp$parent))
    return(fail(paste0(
      "could not reach the BCB API (", .snippet(detail, 200), ")."
    )))
  }

  status <- httr2::resp_status(resp)
  txt    <- tryCatch(httr2::resp_body_string(resp), error = function(e) NA_character_)

  # 2. HTTP status -----------------------------------------------------
  # BCB answers 404 when a window holds no observations (e.g. outside the
  # series' coverage). That is routine, not a failure.
  if (status == 404L) {
    return(no_data(sprintf(
      "The BCB API answered HTTP 404 (no observations in %s to %s).",
      format(start_date, "%Y-%m-%d"), format(end_date, "%Y-%m-%d")
    )))
  }

  if (status != 200L) {
    return(fail(sprintf(
      "the BCB API returned HTTP %s. Response starts with: '%s'.",
      status, .snippet(txt)
    )))
  }

  # 3. Content type (the API can answer 200 with an HTML page) ----------
  ctype <- tryCatch(httr2::resp_content_type(resp), error = function(e) NA_character_)

  if (length(ctype) != 1 || is.na(ctype) || !grepl("json", ctype, ignore.case = TRUE)) {
    return(fail(sprintf(
      "expected JSON but the BCB API returned content type '%s' (service unavailable, blocking requests or changed). Response starts with: '%s'.",
      if (length(ctype) != 1 || is.na(ctype)) "none" else ctype,
      .snippet(txt)
    )))
  }

  if (is.na(txt) || !grepl("^[[:space:]]*[\\[{]", txt)) {
    return(fail(sprintf(
      "the BCB API response is not valid JSON. Response starts with: '%s'.",
      .snippet(txt)
    )))
  }

  # 4. Parse JSON ------------------------------------------------------
  parsed <- tryCatch(
    jsonlite::fromJSON(txt, simplifyVector = TRUE),
    error = function(e) e
  )

  if (inherits(parsed, "error")) {
    return(fail(paste0(
      "could not parse the BCB API response (", .snippet(conditionMessage(parsed), 200), ")."
    )))
  }

  # 5. Validate structure ----------------------------------------------
  # A valid answer is a table with columns `data` and `valor`. A JSON object
  # (e.g. an error payload) is NOT a table and must not reach the cleaning step.
  if (!is.data.frame(parsed)) {
    if (length(parsed) == 0) {
      return(no_data("The BCB API returned an empty answer."))
    }
    return(fail(sprintf(
      "the BCB API response has an unexpected structure (not a table of observations). Response starts with: '%s'.",
      .snippet(txt)
    )))
  }

  if (!all(c("data", "valor") %in% names(parsed))) {
    return(fail(sprintf(
      "the BCB API response has unexpected columns (%s; expected 'data' and 'valor'). The API format may have changed.",
      paste(names(parsed), collapse = ", ")
    )))
  }

  if (nrow(parsed) == 0) {
    return(no_data("The BCB API returned no observations."))
  }

  # 6. Clean (base R: no data-masking, so a column called `data` is harmless)
  datas <- as.Date(as.character(parsed$data), format = "%d/%m/%Y")

  if (all(is.na(datas))) {
    return(fail(
      "could not read the dates returned by the BCB API (expected dd/mm/yyyy). The API format may have changed."
    ))
  }

  df <- data.frame(
    date  = datas,
    value = suppressWarnings(as.numeric(gsub(",", ".", as.character(parsed$valor), fixed = TRUE))),
    stringsAsFactors = FALSE
  )

  df <- df[!is.na(df$date) & df$date >= start_date & df$date <= end_date, , drop = FALSE]
  df <- df[order(df$date), , drop = FALSE]
  rownames(df) <- NULL

  list(ok = TRUE, data = df, note = NULL)
}

# -------------------------------------------------------------------
# Date normalization
# -------------------------------------------------------------------

.normalize_date <- function(x, is_start = TRUE) {

  # NULL: start = 30 days ago, end = today
  if (is.null(x)) {
    return(if (is_start) Sys.Date() - 30 else Sys.Date())
  }

  if (inherits(x, "Date") && length(x) == 1 && !is.na(x)) {
    return(x)
  }

  x <- as.character(x)

  bad <- function() {
    stop(
      sprintf(
        "Invalid date format: '%s'. Use: NULL, YYYY, YYYY-MM, or YYYY-MM-DD",
        paste(x, collapse = ", ")
      ),
      call. = FALSE
    )
  }

  parse_ymd <- function(s) tryCatch(as.Date(s), error = function(e) NA)

  if (length(x) != 1 || is.na(x)) bad()

  # Year only: "2020"
  if (grepl("^\\d{4}$", x)) {
    return(as.Date(paste0(x, if (is_start) "-01-01" else "-12-31")))
  }

  # Year-month: "2020-06" (end = real last day of the month)
  if (grepl("^\\d{4}-\\d{2}$", x)) {
    primeiro_dia <- parse_ymd(paste0(x, "-01"))
    if (is.na(primeiro_dia)) bad()
    if (is_start) return(primeiro_dia)
    return(seq(primeiro_dia, by = "1 month", length.out = 2)[2] - 1)
  }

  # Full date: "2020-06-15"
  out <- parse_ymd(x)
  if (is.na(out)) bad()
  out
}
