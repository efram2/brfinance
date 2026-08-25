#' Download SGS series from Brazilian Central Bank
#'
#' Internal helper function to download time series data from BCB SGS API.
#' Uses httr2 for robust HTTP requests with automatic fallback strategy.
#' Requests spanning more than 10 years are automatically split into
#' consecutive 9-year windows and stitched back together, since the BCB
#' API rejects date ranges longer than 10 years in a single call (9 years
#' is used instead of 10 to stay safely clear of that boundary).
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

  # Declare global variables
  value <- data <- valor <- NULL

  # Normalize dates
  start_date <- .normalize_date(start_date, is_start = TRUE)
  end_date   <- .normalize_date(end_date, is_start = FALSE)

  # === CHUNKING: BCB API rejects windows longer than 10 years ===
  # Using 9 years (not 10) as the chunk size deliberately: a window of
  # "10 years minus 1 day" sits right at the API's boundary, and depending
  # on how many leap years fall inside it, the actual day count can creep
  # past what the API accepts. 9 years leaves enough margin to never
  # brush that edge, at the cost of a couple of extra requests.
  janelas <- .split_date_windows(start_date, end_date, max_years = 9)

  partes <- lapply(seq_len(nrow(janelas)), function(i) {
    .download_sgs_window(
      series_id = series_id,
      start_date = janelas$start[i],
      end_date = janelas$end[i]
    )
  })

  df <- dplyr::bind_rows(partes)

  # Remove possible duplicate boundary dates between consecutive chunks
  # and re-sort, since each window is inclusive on both ends.
  if (nrow(df) > 0) {
    df <- df |>
      dplyr::distinct(date, .keep_all = TRUE) |>
      dplyr::arrange(date)
  }

  if (nrow(df) == 0) {
    message(sprintf(
      "Series %s has no data for requested period (%s to %s).",
      series_id,
      format(start_date, "%Y-%m"),
      format(end_date, "%Y-%m")
    ))

    return(data.frame(date = as.Date(character()), value = numeric()))
  }

  return(df)
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

  starts <- start_date
  ends <- c()

  cursor <- start_date

  while (cursor < end_date) {
    # Window end: cursor + max_years - 1 day, capped at end_date
    janela_fim <- min(
      seq(cursor, by = paste(max_years, "years"), length.out = 2)[2] - 1,
      end_date
    )

    ends <- c(ends, janela_fim)

    if (janela_fim >= end_date) break

    cursor <- janela_fim + 1
    starts <- c(starts, cursor)
  }

  data.frame(
    start = as.Date(starts, origin = "1970-01-01"),
    end   = as.Date(ends, origin = "1970-01-01")
  )
}

# -------------------------------------------------------------------
# Download a single (<= 10 year) window from the BCB SGS API
# -------------------------------------------------------------------

#' @keywords internal
#' @noRd
.download_sgs_window <- function(series_id, start_date, end_date) {

  value <- data <- valor <- NULL

  dados_baixados <- tryCatch({

    url_filtrado <- sprintf(
      'https://api.bcb.gov.br/dados/serie/bcdata.sgs.%s/dados?formato=json&dataInicial=%s&dataFinal=%s',
      series_id,
      format(start_date, '%d/%m/%Y'),
      format(end_date, '%d/%m/%Y')
    )

    resposta <- httr2::request(url_filtrado) |>
      httr2::req_timeout(60) |>                              # BCB pode demorar em janelas grandes; 10s era curto demais
      httr2::req_retry(max_tries = 3, backoff = ~ 2) |>       # tenta de novo em falhas transitorias de rede/timeout
      httr2::req_error(is_error = function(resp) FALSE) |>   # NAO lancar erro automatico por status HTTP
      httr2::req_perform()

    status <- httr2::resp_status(resposta)

    if (status == 404) {
      # BCB uses 404 to mean "no data points exist in this specific date
      # range" -- not a real failure. This is expected/routine whenever a
      # requested window falls outside a series' actual coverage (e.g. GDP
      # series 2010, which only has data up to 2014) or is too narrow to
      # catch a low-frequency series' next release. Treat it as "no data"
      # rather than raising the generic failure path below.
      return(list(status_404 = TRUE))
    }

    if (status != 200) {
      stop(sprintf(
        "HTTP %s. Body: %s",
        status,
        substr(httr2::resp_body_string(resposta), 1, 300)
      ))
    }

    httr2::resp_body_json(resposta, simplifyVector = TRUE)

  }, error = function(e) {

    # Surface the REAL underlying error (timeout, DNS, SSL, HTTP status, etc.)
    # instead of a generic "unavailable" message that hides what actually
    # went wrong and makes debugging impossible.
    message(sprintf(
      "Series %s (%s a %s): request failed - %s",
      series_id, format(start_date, "%Y-%m-%d"), format(end_date, "%Y-%m-%d"),
      conditionMessage(e)
    ))

    return(NULL)
  })

  if (is.list(dados_baixados) && isTRUE(dados_baixados$status_404)) {
    message(sprintf(
      "Series %s: no data in %s to %s (normal if this window falls outside the series' coverage).",
      series_id, format(start_date, "%Y-%m-%d"), format(end_date, "%Y-%m-%d")
    ))
    return(data.frame(date = as.Date(character()), value = numeric()))
  }

  if (is.null(dados_baixados) || length(dados_baixados) == 0) {
    return(data.frame(
      date = as.Date(character()),
      value = numeric()
    ))
  }

  # Convert to data.frame (handle both list and data.frame returns)
  if (is.data.frame(dados_baixados)) {
    df <- dados_baixados
  } else {
    df <- dplyr::bind_rows(dados_baixados)
  }

  # Clean and standardize
  df <- df |>
    dplyr::mutate(
      date = as.Date(data, format = "%d/%m/%Y"),
      value = as.numeric(gsub(",", ".", valor, fixed = TRUE))
    ) |>
    dplyr::arrange(date) |>
    dplyr::select(date, value)

  # Apply date filters locally (ensures precision)
  dplyr::filter(df, date >= start_date & date <= end_date)
}

# NORMALIZAÇÃO DE DATAS

.normalize_date <- function(x, is_start = TRUE) {

  # Handle NULL: start = 30 days ago, end = today
  if (is.null(x)) {
    return(if (is_start) Sys.Date() - 30 else Sys.Date())
  }

  # Ensure character
  x <- as.character(x)

  # Year only: "2020"
  if (nchar(x) == 4 && grepl("^\\d{4}$", x)) {
    return(as.Date(paste0(x, if (is_start) "-01-01" else "-12-31")))
  }

  # Year-month: "2020-06"
  if (nchar(x) == 7 && grepl("^\\d{4}-\\d{2}$", x)) {
    if (is_start) {
      return(as.Date(paste0(x, "-01")))
    } else {
      primeiro_dia <- as.Date(paste0(x, "-01"))
      proximo_mes <- seq(primeiro_dia, by = "1 month", length.out = 2)[2]
      return(proximo_mes - 1)
    }
  }

  # Full date: "2020-06-15"
  tryCatch(
    as.Date(x),
    error = function(e) {
      stop(
        sprintf(
          "Invalid date format: '%s'. Use: NULL, YYYY, YYYY-MM, or YYYY-MM-DD",
          x
        ),
        call. = FALSE
      )
    }
  )
}
