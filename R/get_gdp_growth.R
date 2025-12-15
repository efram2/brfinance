#' Get GDP Growth Rate
#'
#' Downloads quarterly GDP growth data (% change) from BCB/SGS.
#'
#' @param start_date Start date in "YYYY-MM-DD" format. Default is "2000-01-01".
#' @param end_date End date in "YYYY-MM-DD" format. Default is NULL (most recent data).
#' @param language Language for column names: "pt" for Portuguese or "eng" (default) for English.
#' @param labels By default it is TRUE, if you do not want labels use FALSE.
#'
#' @return A data.frame with GDP growth rate.
#'
#' @examples
#' \dontrun{
#'   df <- get_gdp_growth()
#'
#'   # Specific period
#'   df2 <- get_gdp_growth("2015-01-01", "2020-12-01")
#'
#'   # By a specific date (from the beginning until 2000)
#'   df3 <- get_gdp_growth(end_date = "2020-12-01")
#'
#'   # With language in Portuguese
#'   df4 <- get_gdp_growth(language = "pt")
#'
#'   df5 <- get_gdp_growth("2015-01-01", "2020-12-01", language = "pt")
#' }
#'
#' @export
get_gdp_growth <- function(start_date = "2000-01-01",
                           end_date = NULL,
                           language = "eng",
                           labels = TRUE) {

  # Declaration of global variables
  gdp_growth <- gdp_nominal <- NULL

  url <- "https://api.bcb.gov.br/dados/serie/bcdata.sgs.2010/dados?formato=json"

  data <- jsonlite::fromJSON(url) |>
    dplyr::mutate(
      data = as.Date(data, format = "%d/%m/%Y"),
      gdp_nominal = as.numeric(valor)
    ) |>
    dplyr::arrange(date) |>
    dplyr::mutate(
      gdp_growth = (gdp_nominal / dplyr::lag(gdp_nominal) - 1) * 100
    )

  if (!is.null(end_date)) {
    data <- dplyr::filter(data, date <= as.Date(end_date))
  }

  if (tolower(language) == "pt") {
    data <- dplyr::rename(
      data,
      data_referencia = date,
      crescimento_pib = gdp_growth
    )
  }

  if (isTRUE(labels) && requireNamespace("labelled", quietly = TRUE)) {
    if (language == "pt") {
      data <- labelled::set_variable_labels(
        data,
        data_referencia = "Trimestre de referencia",
        crescimento_pib = "Crescimento do PIB real (%)"
      )
    } else {
      data <- labelled::set_variable_labels(
        data,
        date = "Reference quarter",
        gdp_growth = "GDP growth rate (%)"
      )
    }
  }

  return(data)
}
