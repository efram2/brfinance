#' Retrieve Brazil's quarterly unemployment rate
#'
#' Downloads and cleans data from IBGE's Continuous PNAD via SIDRA API.
#'
#' @param start_year Starting year (e.g., 2015)
#' @param end_year Ending year (e.g., 2024)
#' @param language Language of labels: "eng" (default) or "pt"
#'
#' @return A tibble with columns: `date` and `rate`
#' @export
#'
#' @examples
#' \dontrun{
#' data <- get_unemployment(2018, 2024, language = "pt")
#' }

get_unemployment <- function(start_year, end_year, language = "eng") {
  if (!requireNamespace("sidrar", quietly = TRUE)) {
    stop("The 'sidrar' package is required. Install with install.packages('sidrar')", call. = FALSE)
  }

  dados <- sidrar::get_sidra(api = "/t/6381/n1/all/v/4099/p/all/d/v4099%201")

  df <- dados |>
    janitor::clean_names() |>
    dplyr::select("trimestre_movel", "valor") |>
    dplyr::rename(trimestre = "trimestre_movel", rate = valor) |>
    dplyr::mutate(
      month = stringr::str_extract(trimestre, "(jan|fev|mar|abr|mai|jun|jul|ago|set|out|nov|dez)(?=\\s)"),
      year = as.numeric(stringr::str_extract(trimestre, "\\d{4}$")),
      date = lubridate::dmy(paste("01", month, year))
    ) |>
    dplyr::filter(year >= start_year & year <= end_year)

  # Se o idioma for português, adiciona atributo
  attr(df, "language") <- match.arg(language, c("eng", "pt"))
  return(df)
}
