#' Download a SGS time series from the Brazilian Central Bank
#'
#' Internal helper function to download and format time series
#' data from the Central Bank of Brazil (SGS API).
#'
#' @param series_id Numeric. SGS series ID.
#' @param start_date Optional start date ("YYYY-MM-DD").
#' @param end_date Optional end date ("YYYY-MM-DD").
#'
#' @return A data.frame with columns:
#' \describe{
#'   \item{date}{Reference date.}
#'   \item{value}{Series value.}
#' }
#'
#' @keywords internal
.get_sgs_series <- function(series_id,
                            start_date = NULL,
                            end_date = NULL) {

  url <- paste0(
    "https://api.bcb.gov.br/dados/serie/bcdata.sgs.",
    series_id,
    "/dados?formato=json"
  )

  data <- jsonlite::fromJSON(url) |>
    dplyr::mutate(
      date = as.Date(data, format = "%d/%m/%Y"),
      value = as.numeric(valor)
    ) |>
    dplyr::select(date, value)

  if (!is.null(start_date)) {
    data <- dplyr::filter(data, date >= as.Date(start_date))
  }

  if (!is.null(end_date)) {
    data <- dplyr::filter(data, date <= as.Date(end_date))
  }

  return(data)
}
