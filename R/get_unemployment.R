#' Get Brazilian Unemployment Rate (PNAD Continua)
#'
#' Downloads monthly unemployment rate data from the Brazilian Central Bank's
#' SGS (Sistema Gerenciador de Series Temporais). The series corresponds to the
#' unemployment rate from IBGE's Continuous PNAD survey (PNAD Continua),
#' replicated and made available by the Central Bank.
#'
#' @param start_date Start date for the data period. Accepts multiple formats:
#'   - `"YYYY"` for year only (e.g., `"2020"` becomes `"2020-01-01"`)
#'   - `"YYYY-MM"` for year and month (e.g., `"2020-06"` becomes `"2020-06-01"`)
#'   - `"YYYY-MM-DD"` for a specific date
#'   - `NULL` defaults to `"2020-01-01"`
#' @param end_date End date for the data period. Accepts the same formats as `start_date`.
#'   - `NULL` defaults to the current date
#' @param language Language for column names in the returned data.frame:
#'   - `"eng"` (default): Returns columns `date`, `unemployment_rate`
#'   - `"pt"`: Returns columns `data`, `taxa_desemprego`
#' @param labels Logical indicating whether to add variable labels using the
#'   `labelled` package.
#'
#' @return A data.frame with:
#'   - date (Date): Reference month
#'   - value (numeric): Unemployment rate (%)
#'
#' @note
#' **Data Source**: Brazilian Central Bank (SGS), series 24369.
#' The data originates from IBGE's Continuous National Household Sample Survey
#' (PNAD Continua) and is published with monthly frequency.
#'
#' Although published monthly, the unemployment rate follows IBGE's
#' moving-quarter methodology.
#'
#' @examplesIf interactive()
#'   # Default: from 2020 to current date (aligned with other functions)
#'   df <- get_unemployment()
#'
#'   # Specific period with year-only format
#'   df2 <- get_unemployment("2018", "2023")
#'
#'   # Portuguese column names and labels
#'   df3 <- get_unemployment(language = "pt")
#'
#'   # Without variable labels
#'   df4 <- get_unemployment("2020-01-01", "2022-12-31", labels = FALSE)
#'
#' @export
get_unemployment <- function(start_date = "2020-01-01",
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

  # === DATE NORMALIZATION ===
  start_date_norm <- .normalize_date(start_date, is_start = TRUE)
  end_date_norm   <- .normalize_date(end_date, is_start = FALSE)

  # === DOWNLOAD DATA FROM SGS (SERIES 24369) ===
  dados <- .get_sgs_series(
    series_id = 24369,
    start_date = format(start_date_norm, "%Y-%m-%d"),
    end_date   = format(end_date_norm, "%Y-%m-%d")
  )

  # === FILTER EXACT DATE RANGE ===
  df <- dados

  # === ADD LABELS IF REQUESTED ===
  if (isTRUE(labels) && requireNamespace("labelled", quietly = TRUE)) {

    if (language == "pt") {
      df <- labelled::set_variable_labels(
        df,
        date = "Mes de referencia",
        value = "Taxa de desemprego (%)"
      )
    } else {
      df <- labelled::set_variable_labels(
        df,
        date = "Reference month",
        value = "Unemployment rate (%)"
      )
    }
  }

  return(df)
}
