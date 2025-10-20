#' Get IPCA Inflation Data
#'
#' Downloads monthly IPCA inflation data from the Brazilian Central Bank (BCB)
#' and calculates both year-to-date (YTD) and 12-month accumulated inflation.
#'
#' @param start_date Start date in "YYYY-MM-DD" format. Default is "2012-01-01".
#' @param end_date End date in "YYYY-MM-DD" format. Default is NULL (most recent data).
#' @param language Output language: "en" (English, default) or "pt" (Português).
#'
#' @return A data.frame with:
#' \describe{
#'   \item{date}{Reference date (month).}
#'   \item{monthly_inflation}{Monthly IPCA variation (%).}
#'   \item{ytd_inflation}{Accumulated inflation in the current year (%).}
#'   \item{twelve_month_inflation}{Accumulated inflation over the last 12 months (%).}
#' }
#'
#' @examples
#' \dontrun{
#'   # Complete data (default)
#'   df <- get_inflation_rate()
#'
#'   # Specific period
#'   df <- get_inflation_rate("2015-01-01", "2020-12-01")
#'
#'   # By a specific date (from the beginning until 2020)
#'   df <- get_inflation_rate(end_date = "2020-12-01")
#'
#'   # With language in Portuguese
#'   df <- get_inflation_rate("2015-01-01", "2020-12-01", language = "pt")
#' }
#'
#' @export

get_inflation_rate <- function(start_date = "2012-01-01",
                               end_date = NULL,
                               language = "eng") {

  # Calculate start date for data download (12 months earlier)
  download_start_date <- as.Date(start_date) - lubridate::years(1)
  download_start_date <- format(download_start_date, "%d/%m/%Y")

  url <- paste0(
    "https://api.bcb.gov.br/dados/serie/bcdata.sgs.433/dados?formato=json&",
    "dataInicial=", download_start_date
  )

  data <- jsonlite::fromJSON("https://api.bcb.gov.br/dados/serie/bcdata.sgs.433/dados?formato=json")

  data <- data |>
    dplyr::mutate(
      date = as.Date(data, format = "%d/%m/%Y"),
      monthly_inflation = as.numeric(valor)
    ) |>
    dplyr::select(date, monthly_inflation) |>
    dplyr::filter(date >= (as.Date(start_date) - lubridate::years(1)))  # Keep extra 12 months for calculation

  # Filtro para data final (end_date)
  if (!is.null(end_date)) {
    data <- data |>
      dplyr::filter(date <= as.Date(end_date))
  }

  # Add year variable
  data <- dplyr::mutate(data, year = lubridate::year(date))

  # Year-to-date accumulated inflation
  data <- data |>
    dplyr::group_by(year) |>
    dplyr::mutate(
      ytd_inflation = (cumprod(1 + monthly_inflation / 100) - 1) * 100
    ) |>
    dplyr::ungroup()

  # 12-month accumulated inflation
  data <- data |>
    dplyr::arrange(date) |>
    dplyr::mutate(
      twelve_month_inflation = sapply(seq_along(monthly_inflation), function(i) {
        if (i < 12) return(NA)
        (prod(1 + monthly_inflation[(i-11):i] / 100) - 1) * 100
      })
    )

  # Filter to show only the requested period
  data <- data |>
    dplyr::filter(date >= as.Date(start_date))

  # Translate column names if language = "pt"
  if (tolower(language) == "pt") {
    data <- dplyr::rename(
      data,
      data_referencia = date,
      inflacao_mensal = monthly_inflation,
      ano = year,
      inflacao_acumulada_ano = ytd_inflation,
      inflacao_12_meses = twelve_month_inflation
    )
  }

  # Add descriptive labels (requires labelled package)
  if (requireNamespace("labelled", quietly = TRUE)) {
    if (language == "pt") {
      data <- labelled::set_variable_labels(
        data,
        data_referencia = "Mes de referencia",
        inflacao_mensal = "Variacao mensal do IPCA (%)",
        inflacao_acumulada_ano = "Inflacao acumulada no ano (%)",
        inflacao_12_meses = "Inflacao acumulada nos ultimos 12 meses (%)"
      )
    } else {
      data <- labelled::set_variable_labels(
        data,
        date = "Reference month",
        monthly_inflation = "Monthly IPCA variation (%)",
        ytd_inflation = "Year-to-date accumulated inflation (%)",
        twelve_month_inflation = "12-month accumulated inflation (%)"
      )
    }
  }

  return(data)
}
