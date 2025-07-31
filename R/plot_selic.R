#' Plot daily Brazilian interest rate (annualized, base 252) as a line chart
#'
#' Generates a time series plot of the basic interest rate of the Brazilian economy,
#' commonly referred to as the SELIC rate ("Sistema Especial de Liquidação e de Custódia").
#' This rate reflects the effective overnight interest rate for interbank loans
#' and is a key instrument of Brazil's monetary policy.
#'
#' The data used in this plot corresponds to the **effective SELIC Over rate**, annualized
#' on a **252-business-day basis**, and is retrieved from series 1178 of the SGS
#' ("Sistema Gerenciador de Séries Temporais" – Time Series Management System),
#' the Central Bank of Brazil’s official repository for economic time series.
#'
#' API documentation available at:
#' <https://dadosabertos.bcb.gov.br/dataset/1178-taxa-de-juros---selic-anualizada-base-252>
#'
#' Important notice: Starting March 26, 2025, the 'Central Bank of Brazil' will limit
#' the amount of data returned for daily historical series in JSON and CSV formats.
#' Queries using date ranges will be restricted to a maximum span of 10 years.
#' Requests exceeding this range will return an error.
#'
#' @param start_year Starting year (e.g., 2020)
#' @param end_year Ending year (e.g., 2024)
#'
#' @details The maximum supported interval is 9 years. For performance and compatibility
#' with the API, longer time spans are not allowed and will return an error.
#'
#' @return A `ggplot2` object showing the Brazilian interest rate over time.
#' @export
#'
#' @examples
#' \dontrun{
#' plot_selic(2020, 2024)
#' }

plot_selic <- function(start_year,
                       end_year) {

  # Converte anos para datas completas
  data_inicio <- as.Date(paste0(start_year, "-01-01"))
  data_fim <- as.Date(paste0(end_year, "-12-31"))

  # Monta URL com função auxiliar
  url <- get_selic_url(data_inicio, data_fim)

  # Requisição à API do BCB
  dados <- try({
    url |>
      httr2::request() |>
      httr2::req_perform() |>
      httr2::resp_body_json()
  }, silent = TRUE)

  if (inherits(dados, "try-error") || is.null(dados)) {
    warning("Erro ao buscar dados da API do BCB.")
    return(ggplot2::ggplot() + ggplot2::labs(title = "Erro ao buscar dados da SELIC"))
  }

  # Converte e trata os dados
  df <- dplyr::bind_rows(dados) |>
    dplyr::mutate(
      data = as.Date(data, format = "%d/%m/%Y"),
      valor = as.numeric(gsub(",", ".", valor))
    )

  # Gera gráfico
  ggplot2::ggplot(df, ggplot2::aes(x = data, y = valor)) +
    ggplot2::geom_step(color = "#1f78b4", linewidth = 1) +
    ggplot2::geom_point(color = "#e31a1c", size = 1) +
    ggplot2::scale_x_date(date_breaks = "6 months", date_labels = "%b/%Y") +
    ggplot2::scale_y_continuous(labels = scales::label_number(suffix = "%")) +
    ggplot2::labs(
      title = "Brasil | Meta da SELIC definida pelo COPOM",
      subtitle = paste("Entre", format(data_inicio, "%d/%m/%Y"), "e", format(data_fim, "%d/%m/%Y")),
      x = NULL,
      y = "Taxa SELIC (% a.a.)",
      caption = "Fonte: Banco Central do Brasil (SGS 432)"
    ) +
    ggplot2::theme_minimal(base_size = 14) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(face = "bold", hjust = 0.5),
      axis.text.x = ggplot2::element_text(angle = 45, hjust = 1)
    )
}

# Função auxiliar usada internamente
#' @keywords internal
get_selic_url <- function(first.date, last.date) {
  sprintf(
    paste0('https://api.bcb.gov.br/dados/serie/bcdata.sgs.1178/dados?',
           'formato=json&dataInicial=%s&dataFinal=%s'),
    format(first.date, '%d/%m/%Y'),
    format(last.date, '%d/%m/%Y')
  )
}
