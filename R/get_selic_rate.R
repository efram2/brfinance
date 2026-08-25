#' Get Daily Brazilian SELIC Rate (Daily and Annualized)
#'
#' Downloads the daily SELIC rate series from the Central Bank of Brazil's SGS API.
#' The SELIC rate (Special System for Settlement and Custody) is Brazil's benchmark
#' overnight interest rate, used as the primary monetary policy instrument. Returns
#' both the raw daily rate and its annualized (base-252) equivalent, mirroring the
#' pattern already used by `get_cdi_rate()`.
#'
#' @note
#' **Series information**: This function uses SGS series **11** ("Taxa de
#' juros - Selic"), the daily-quoted average rate of overnight repo
#' operations backed by federal government securities held in the Selic
#' system, published in % per day (% a.d.). The annualized column
#' (`value_annualized`) is computed locally from that daily rate using the
#' standard 252-business-day compounding formula:
#' `((1 + value/100)^252 - 1) * 100` — the same formula `get_cdi_rate()`
#' already uses for its own `value_annualized` column. This is offered as an
#' alternative to fetching SGS series 1178 ("Selic anualizada base 252")
#' directly, which is BCB's own officially published annualized series and
#' may differ from the locally-computed value by rounding. Data is available
#' from June 4, 1986 onward. Requests spanning more than 10 years are split
#' and stitched together automatically (see `.get_sgs_series()`), so the
#' BCB's 10-year window limit no longer needs to be handled manually.
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
#'   to the returned data.frame ("eng" or "pt"). The column names themselves
#'   are always `date`, `value` and `value_annualized`, so output plugs
#'   directly into `plot_selic_rate()` and the rest of the package pipeline
#'   regardless of `language`.
#' @param labels Logical indicating whether to add variable labels using the `labelled`
#'   package. Labels provide descriptive text for each column when available.
#'
#' @return A data.frame with columns:
#' \describe{
#'   \item{date}{Reference date}
#'   \item{value}{Daily SELIC rate (% per day)}
#'   \item{value_annualized}{Annualized SELIC rate (% per year, 252 business days)}
#' }
#'
#' @examples
#' \donttest{
#'   # Default: from 2020 to current date
#'   df <- get_selic_rate()
#'   head(df)  # date, value (daily), value_annualized
#'
#'   # Specific period
#'   df2 <- get_selic_rate("2020-01-01", "2023-12-31")
#'
#'   # Long historical window (>10 years) — chunked automatically
#'   df3 <- get_selic_rate(start_date = "2005")
#'
#'   # Portuguese labels
#'   df4 <- get_selic_rate(language = "pt")
#'
#'   # Complete year analysis
#'   df5 <- get_selic_rate("2018", "2023")
#'   }
#'
#' @export
get_selic_rate <- function(start_date = NULL,
                           end_date = NULL,
                           language = "eng",
                           labels = TRUE) {

  # === PARAMETER VALIDATION ===
  # Validate 'language' parameter
  if (!is.character(language) || length(language) != 1) {
    stop("'language' must be a single character string ('eng' or 'pt')", call. = FALSE)
  }

  language <- tolower(language)
  if (!language %in% c("eng", "pt")) {
    stop("'language' must be either 'eng' (English) or 'pt' (Portuguese)", call. = FALSE)
  }

  # Validate 'labels' parameter
  if (!is.logical(labels) || length(labels) != 1) {
    stop("'labels' must be a single logical value (TRUE or FALSE)", call. = FALSE)
  }

  start_date <- start_date
  end_date   <- end_date

  # === FUNCTION BODY ===
  # Declare global variables for dplyr operations
  value <- value_annualized <- NULL

  # SGS 11 = Taxa de juros - Selic (série diária, % a.d.)
  data <- .get_sgs_series(
    series_id = 11,
    start_date = start_date,
    end_date = end_date
  )

  # Process the data
  # NOTE: columns are always `date`/`value`/`value_annualized`, regardless
  # of `language`, so get_*() output plugs directly into plot_selic_rate()
  # and the rest of the pipeline without renaming. `language` controls only
  # the *labelled* metadata below (visible via labelled::var_label()).
  data <- data |>
    dplyr::arrange(date) |>
    dplyr::mutate(
      value_annualized = ((1 + value / 100)^252 - 1) * 100
    ) |>
    dplyr::select(
      date,
      value,
      value_annualized
    )

  # === VARIABLE LABELS ===
  if (isTRUE(labels) && requireNamespace("labelled", quietly = TRUE)) {

    if (language == "pt") {
      data <- labelled::set_variable_labels(
        data,
        date = "Data de referencia",
        value = "Taxa SELIC diaria (% ao dia)",
        value_annualized = "Taxa SELIC anualizada (% ao ano, 252 dias uteis)"
      )
    } else {
      data <- labelled::set_variable_labels(
        data,
        date = "Reference date",
        value = "Daily SELIC rate (% per day)",
        value_annualized = "Annualized SELIC rate (% per year, 252 business days)"
      )
    }
  }

  return(data)
}
