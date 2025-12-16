#' Get Daily Brazilian SELIC Rate (Annualized, Base 252)
#'
#' Downloads the daily SELIC rate series from the Central Bank of Brazil's SGS API.
#' The SELIC rate (Special System for Settlement and Custody) is Brazil's benchmark
#' overnight interest rate, used as the primary monetary policy instrument.
#'
#' @param start_date Start date for the data period. Accepts multiple formats:
#'   - `"YYYY"` for year only (e.g., `"2020"` becomes `"2020-01-01"`)
#'   - `"YYYY-MM"` for year and month (e.g., `"2020-06"` becomes `"2020-06-01"`)
#'   - `"YYYY-MM-DD"` for a specific date (e.g., `"2020-06-15"`)
#' @param end_date End date for the data period. Accepts the same formats as `start_date`:
#'   - `"YYYY"` (e.g., `"2023"` becomes `"2023-12-31"`)
#'   - `"YYYY-MM"` (e.g., `"2023-12"` becomes the last day of December 2023)
#'   - `"YYYY-MM-DD"` for a specific date
#'   - `NULL` defaults to the current date (today)
#' @param language Language for column names in the returned data.frame:
#'   - `"eng"` (default): Returns columns `date` and `selic_rate`
#'   - `"pt"`: Returns columns `data_referencia` and `taxa_selic`
#' @param labels Logical indicating whether to add variable labels using the `labelled`
#'   package. Labels provide descriptive text for each column when available.
#'
#' @return A data.frame with SELIC rate. Columns depend on the `language` parameter:
#'   - English (`language = "eng"`): `date` (Date), `selic_rate` (numeric, % per year)
#'   - Portuguese (`language = "pt"`): `data_referencia` (Date), `taxa_selic` (numeric, % ao ano)
#'
#' @note
#' **IMPORTANT API LIMITATION**: The BCB API imposes a **10-year maximum window**
#' for daily frequency series like SELIC. Requests spanning more than 10 years will fail.
#' For longer historical analyses, split your request into multiple 10-year periods.
#'
#' @examples
#' \dontrun{
#'   # Default: last 30 days of SELIC rate
#'   df <- get_selic_rate()
#'
#'   # Specific period within 10-year limit
#'   df2 <- get_selic_rate("2020-01-01", "2023-12-31")
#'
#'   # Using year-only format (respects 10-year limit)
#'   df3 <- get_selic_rate("2015", "2024")
#'
#'   # Portuguese column names and labels
#'   df4 <- get_selic_rate(language = "pt")
#'
#'   # Current year only
#'   df5 <- get_selic_rate(start_date = format(Sys.Date(), "%Y"))
#' }
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

  # CRÍTICO: Verificar limite de 10 anos para séries diárias
  data_inicio <- .normalize_date(start_date, is_start = TRUE)
  data_fim <- .normalize_date(end_date, is_start = FALSE)

  # Calcula diferença em anos
  diff_years <- as.numeric(difftime(data_fim, data_inicio, units = "days")) / 365.25

  if (diff_years > 10) {
    stop(
      sprintf(
        "SELIC series has a 10-year maximum window (BCB API limitation).\nRequested period: %.1f years (%s to %s).\nPlease split into multiple requests.",
        diff_years,
        format(data_inicio, "%Y-%m-%d"),
        format(data_fim, "%Y-%m-%d")
      ),
      call. = FALSE
    )
  }

  # Set default start_date if NULL (last 30 days by default for SELIC)
  if (is.null(start_date)) {
    start_date <- Sys.Date() - 30  # Last 30 days
    data_inicio <- .normalize_date(start_date, is_start = TRUE)
  }

  # === FUNCTION BODY ===
  # Declare global variables for dplyr operations
  value <- NULL

  # Use internal function to download data (SGS series 1178 = SELIC rate)
  data <- .get_sgs_series(
    series_id = 1178,  # Código da SELIC
    start_date = start_date,
    end_date = end_date
  )

  # Process the data
  data <- data |>
    dplyr::arrange(date) |>
    dplyr::select(
      date,
      selic_rate = value  # Rename for clarity
    )

  # Translation to Portuguese if needed
  if (language == "pt") {
    data <- data |>
      dplyr::rename(
        data_referencia = date,
        taxa_selic = selic_rate
      )
  }

  # Add labels if requested and package is available
  if (isTRUE(labels) && requireNamespace("labelled", quietly = TRUE)) {
    if (language == "pt") {
      data <- labelled::set_variable_labels(
        data,
        data_referencia = "Data de referencia",
        taxa_selic = "Taxa SELIC (% ao ano) - Sistema Especial de Liquidacao e Custodia"
      )
    } else {
      data <- labelled::set_variable_labels(
        data,
        date = "Reference date",
        selic_rate = "SELIC rate (% per year) - Special System for Settlement and Custody"
      )
    }
  }

  return(data)
}
