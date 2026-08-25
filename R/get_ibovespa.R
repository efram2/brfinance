#' Get Ibovespa Index (B3)
#'
#' Downloads the daily closing level of the Ibovespa (Índice Bovespa), Brazil's
#' main stock market benchmark, via Yahoo Finance (ticker `^BVSP`). Uses the
#' `yfR` package, the same data source already used in the `{brstocks}`
#' package, so `{brfinance}` now covers the equity side alongside its
#' macroeconomic series.
#'
#' @param start_date Start date for the data period. Accepts multiple formats:
#'   - `"YYYY"` for year only (e.g., `"2020"` becomes `"2020-01-01"`)
#'   - `"YYYY-MM"` for year and month (e.g., `"2020-06"` becomes `"2020-06-01"`)
#'   - `"YYYY-MM-DD"` for a specific date (e.g., `"2020-06-15"`)
#'   - `NULL` defaults to the last 30 days, using today as the end date
#' @param end_date End date for the data period. Accepts the same formats as `start_date`:
#'   - `"YYYY"` (e.g., `"2023"` becomes `"2023-12-31"`)
#'   - `"YYYY-MM"` (e.g., `"2023-12"` becomes the last day of December 2023)
#'   - `"YYYY-MM-DD"` for a specific date
#'   - `NULL` defaults to the current date (today)
#' @param language Language for the `labelled` variable descriptions attached
#'   to the returned data.frame ("eng" or "pt"). Column names are always
#'   `date` and `value`.
#' @param labels Logical indicating whether to add variable labels using the
#'   `labelled` package.
#'
#' @return A data.frame with columns:
#' \describe{
#'   \item{date}{Trading date}
#'   \item{value}{Ibovespa closing level (index points)}
#' }
#'
#' @note
#' Requires the `yfR` package (`install.packages("yfR")`) and an internet
#' connection to Yahoo Finance. Unlike `get_*()` functions backed by BCB/SGS,
#' this one is not subject to the 10-year window limit — `yfR` handles the
#' full request in one call.
#'
#' @examples
#' \donttest{
#'   # Default: last 12 months
#'   df <- get_ibovespa()
#'
#'   # Specific period
#'   df2 <- get_ibovespa("2020-01-01", "2023-12-31")
#'
#'   # Portuguese labels
#'   df3 <- get_ibovespa(language = "pt")
#'   }
#'
#' @export
get_ibovespa <- function(start_date = NULL,
                         end_date = NULL,
                         language = "eng",
                         labels = TRUE) {

  # === PARAMETER VALIDATION ===
  if (!is.character(language) || length(language) != 1) {
    stop("'language' must be a single character string ('eng' or 'pt')", call. = FALSE)
  }

  language <- tolower(language)
  if (!language %in% c("eng", "pt")) {
    stop("'language' must be either 'eng' (English) or 'pt' (Portuguese)", call. = FALSE)
  }

  if (!is.logical(labels) || length(labels) != 1) {
    stop("'labels' must be a single logical value (TRUE or FALSE)", call. = FALSE)
  }

  if (!requireNamespace("yfR", quietly = TRUE)) {
    stop(
      "The 'yfR' package is required for get_ibovespa(). ",
      "Install it with install.packages('yfR').",
      call. = FALSE
    )
  }

  start_date <- .normalize_date(start_date, is_start = TRUE)
  end_date   <- .normalize_date(end_date, is_start = FALSE)

  # === FUNCTION BODY ===
  # Declare global variables for dplyr operations
  ref_date <- price_close <- ticker <- value <- NULL

  raw <- tryCatch(
    yfR::yf_get(
      tickers = "^BVSP",
      first_date = start_date,
      last_date = end_date
    ),
    error = function(e) {
      message(sprintf("Ibovespa: Yahoo Finance unavailable (%s).", conditionMessage(e)))
      return(NULL)
    }
  )

  if (is.null(raw) || nrow(raw) == 0) {
    return(data.frame(date = as.Date(character()), value = numeric()))
  }

  data <- raw |>
    dplyr::select(date = ref_date, value = price_close) |>
    dplyr::arrange(date)

  # === VARIABLE LABELS ===
  if (isTRUE(labels) && requireNamespace("labelled", quietly = TRUE)) {

    if (language == "pt") {
      data <- labelled::set_variable_labels(
        data,
        date = "Data de referencia",
        value = "Fechamento do Ibovespa (pontos)"
      )
    } else {
      data <- labelled::set_variable_labels(
        data,
        date = "Reference date",
        value = "Ibovespa closing level (index points)"
      )
    }
  }

  return(data)
}
