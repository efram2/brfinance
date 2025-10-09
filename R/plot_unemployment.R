#' Plot Brazil's quarterly unemployment rate
#'
#' Generates a ggplot2 line chart of unemployment rate in Brazil.
#'
#' @param data Tibble returned by `get_unemployment()`
#' @param language Language for column names: "pt" for Portuguese or "eng" (default) for English
#'
#' @return A ggplot2 object
#' @export
#'
#' @examples
#' \dontrun{
#' # Example 1: English version
#' unemployment_data <- get_unemployment(2020, 2024)
#' unemployment_plot <- plot_unemployment(unemployment_data)
#' print(unemployment_plot)
#'
#' # Example 2: Portuguese version
#' dados_desemprego <- get_unemployment(2020, 2024, language = "pt")
#' grafico_desemprego <- plot_unemployment(dados_desemprego, language = "pt")
#' print(grafico_desemprego)
#' }


plot_unemployment <- function(data,
                              language = "eng") {

  lang <- match.arg(language, c("eng", "pt"))

  # Define textos conforme idioma
  if (lang == "pt") {
    title <- "Brasil | Taxa de Desemprego (PNAD Continua)"
    ylab <- "Taxa de Desemprego"
    caption <- "Fonte: IBGE - SIDRA (Tabela 6381)"
  } else {
    title <- "Brazil | Unemployment Rate (Continuous PNAD)"
    ylab <- "Unemployment Rate"
    caption <- "Source: IBGE - SIDRA (Table 6381)"
  }

  ggplot2::ggplot(data, ggplot2::aes(x = date, y = rate)) +
    ggplot2::geom_line(color = "#2c3e50", linewidth = 1) +
    ggplot2::geom_point(color = "#e74c3c", size = 2) +
    ggplot2::theme_minimal(base_size = 14) +
    ggplot2::scale_x_date(date_breaks = "6 months", date_labels = "%b/%Y") +
    ggplot2::scale_y_continuous(labels = scales::label_number(suffix = "%")) +
    ggplot2::labs(
      title = title,
      x = NULL,
      y = ylab,
      caption = caption
    ) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(face = "bold", hjust = 0.5),
      axis.text.x = ggplot2::element_text(angle = 45, hjust = 1)
    )
}
