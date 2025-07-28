#' Plot Brazil's unemployment rate as a line chart
#'
#' Generates a time series plot of Brazil's quarterly unemployment rate,
#' using data from the Continuous PNAD (Pesquisa Nacional por Amostra de Domicílios Continua)
#' provided by the 'IBGE' via the 'SIDRA' API (<https://sidra.ibge.gov.br/>).
#' The graph offers a visual overview of the labor market trends in Brazil over the selected period.
#'
#' @param start_year Starting year (e.g., 2015)
#' @param end_year Ending year (e.g., 2024)
#'
#' @return A `ggplot2` object showing the unemployment rate over time.
#' @export
#'
#' @examples
#' \dontrun{
#' plot_desemprego(2018, 2024)
#' }

plot_desemprego <- function(start_year,
                            end_year) {

  if (!requireNamespace("sidrar", quietly = TRUE)) {
    stop("O pacote 'sidrar' e necessario. Instale com install.packages('sidrar')", call. = FALSE)
  }

  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("O pacote 'ggplot2' e necessario. Instale com install.packages('ggplot2')", call. = FALSE)
  }

  # Baixa os dados da taxa de desocupacao total no Brasil
  dados <- sidrar::get_sidra(api = "/t/6381/n1/all/v/4099/p/all/d/v4099%201")

  df <- dados |>
    janitor::clean_names() |>
    dplyr::select("trimestre_movel", "valor") |>
    dplyr::rename(trimestre = "trimestre_movel", taxa = valor) |>
    dplyr::mutate(
      ultimo_mes = stringr::str_extract(trimestre, "(jan|fev|mar|abr|mai|jun|jul|ago|set|out|nov|dez)(?=\\s)"),
      ano = as.numeric(stringr::str_extract(trimestre, "\\d{4}$")),
      data = lubridate::dmy(paste("01", ultimo_mes, ano))
    ) |>
    dplyr::filter(ano >= start_year & ano <= end_year)

  ggplot2::ggplot(df, ggplot2::aes(x = data, y = taxa)) +
    ggplot2::geom_line(color = "#2c3e50", linewidth = 1) +
    ggplot2::geom_point(color = "#e74c3c", size = 2) +
    ggplot2::theme_minimal(base_size = 14) +
    ggplot2::scale_x_date(date_breaks = "6 months", date_labels = "%b/%Y") +
    ggplot2::scale_y_continuous(labels = scales::label_number(suffix = "%")) +
    ggplot2::labs(
      title = "Brasil | Taxa de Desemprego (PNAD Continua)",
      subtitle = paste("Entre", start_year, "e", end_year),
      x = NULL,
      y = "Taxa de Desemprego",
      caption = "Fonte: IBGE - SIDRA (Tabela 6381)"
    ) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(face = "bold", hjust = 0.5),
      axis.text.x = ggplot2::element_text(angle = 45, hjust = 1)
    )
}
