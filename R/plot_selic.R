#' Visualiza a taxa Selic diária em um gráfico de linha
#'
#' Esta função baixa dados da taxa Selic (código 432 no SGS do Banco Central)
#' e retorna um gráfico de linha usando `ggplot2`.
#'
#' @param ano_inicio Ano inicial (ex: 2020)
#' @param ano_fim Ano final (ex: 2024)
#'
#' @return Um gráfico (`ggplot`) da taxa Selic no período escolhido
#' @export
#'
#' @examples
#' \dontrun{
#' plot_selic(2020, 2024)
#' }

plot_selic <- function(ano_inicio, ano_fim) {
  # Converte anos para datas completas
  data_inicio <- as.Date(paste0(ano_inicio, "-01-01"))
  data_fim <- as.Date(paste0(ano_fim, "-12-31"))

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
    paste0('https://api.bcb.gov.br/dados/serie/bcdata.sgs.432/dados?',
           'formato=json&dataInicial=%s&dataFinal=%s'),
    format(first.date, '%d/%m/%Y'),
    format(last.date, '%d/%m/%Y')
  )
}
