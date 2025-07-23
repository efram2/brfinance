#' Visualiza a taxa Selic diária em um gráfico de linha
#'
#' Esta função baixa dados da taxa Selic (código 1178 no SGS do Banco Central)
#' e retorna um gráfico de linha usando `ggplot2`.
#'
#' @param ano_inicio Data inicial no formato "yyyy-mm-dd"
#' @param ano_fim Data final no formato "yyyy-mm-dd"
#'
#' @return Um gráfico (`ggplot`) da taxa Selic no período escolhido
#' @export
#'
#' @examples
#' \dontrun{
#' plot_selic("2023-01-01", "2024-01-01")
#' }

plot_selic <- function(ano_inicio, ano_fim) {
  url <- paste0(
    "https://api.bcb.gov.br/dados/serie/bcdata.sgs.432/dados?",
    "formato=json&dataInicial=", format(as.Date(ano_inicio), "%d/%m/%Y"),
    "&dataFinal=", format(as.Date(ano_fim), "%d/%m/%Y")
  )

  dados <- httr2::request(url) |>
    httr2::req_perform() |>
    httr2::resp_body_json()

  df <- dplyr::bind_rows(dados) |>
    dplyr::mutate(
      data = lubridate::dmy(data),
      valor = as.numeric(valor)
    )

  ggplot2::ggplot(df, ggplot2::aes(x = data, y = valor)) +
    ggplot2::geom_step(color = "#1f78b4", linewidth = 1) +
    ggplot2::geom_point(color = "#e31a1c", size = 2) +  # pontos nos degraus
    ggplot2::scale_x_date(
      date_breaks = "6 months",
      date_labels = "%b/%Y"
    ) +
    ggplot2::scale_y_continuous(
      labels = scales::label_number(suffix = "%"),
      breaks = scales::pretty_breaks(n = 10)
    ) +
    ggplot2::labs(
      title = "Brasil | Meta da SELIC definida pelo COPOM",
      subtitle = paste("Entre", ano_inicio, "e", ano_fim),
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

