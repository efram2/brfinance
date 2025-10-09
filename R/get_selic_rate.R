#' Get daily Brazilian SELIC rate data (annualized, base 252)
#'
#' Downloads the daily SELIC rate series (ID 1178) from the Central Bank of Brazil’s
#' SGS (Time Series Management System) API. Returns a tidy data frame.
#'
#' @param start_year Starting year (e.g., 2020)
#' @param end_year Ending year (e.g., 2024)
#' @param language Language for column names: "pt" for Portuguese or "eng" (default) for English
#'
#' @return A tibble with SELIC rate data between the selected years.
#' @export
#'
#' @examples
#' \dontrun{
#' selic_data <- get_selic_rate(2020, 2024)
#' }

get_selic_rate <- function(start_year,
                           end_year,
                           language = "eng") {

  if (!requireNamespace("httr2", quietly = TRUE)) {
    stop("The 'httr2' package is required. Install it with install.packages('httr2').")
  }

  data_inicio <- as.Date(paste0(start_year, "-01-01"))
  data_fim <- as.Date(paste0(end_year, "-12-31"))

  # Função auxiliar interna
  get_selic_url <- function(first.date, last.date) {
    sprintf(
      paste0('https://api.bcb.gov.br/dados/serie/bcdata.sgs.1178/dados?',
             'formato=json&dataInicial=%s&dataFinal=%s'),
      format(first.date, '%d/%m/%Y'),
      format(last.date, '%d/%m/%Y')
    )
  }

  url <- get_selic_url(data_inicio, data_fim)

  dados <- try({
    url |>
      httr2::request() |>
      httr2::req_perform() |>
      httr2::resp_body_json()
  }, silent = TRUE)

  if (inherits(dados, "try-error") || is.null(dados)) {
    stop("Erro ao buscar dados da API do Banco Central.")
  }

  df <- dplyr::bind_rows(dados) |>
    dplyr::mutate(
      data = as.Date(data, format = "%d/%m/%Y"),
      valor = as.numeric(gsub(",", ".", valor))
    )

  # Tradução automática dos nomes das colunas
  if (language == "eng") {
    df <- df |>
      dplyr::rename(date = data, rate = valor)
  } else {
    df <- df |>
      dplyr::rename(data = data, taxa = valor)
  }

  return(df)
}

