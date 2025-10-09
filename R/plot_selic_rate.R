#' Plot Brazilian SELIC rate (annualized, base 252)
#'
#' Generates a time series plot of the SELIC interest rate using data from `get_selic()`.
#' The SELIC rate ("Sistema Especial de Liquidação e de Custódia") represents the
#' effective annualized rate (252-business-day basis) for overnight interbank loans
#' and is the main instrument of Brazil’s monetary policy.
#'
#' @param start_year Starting year (e.g., 2020)
#' @param end_year Ending year (e.g., 2024)
#' @param language Language for titles and labels: "pt" (Portuguese) or "eng" (English).
#'
#' @return A `ggplot2` object showing the SELIC rate over time.
#' @export
#'
#' @examples
#' \dontrun{
#' plot_selic_rate(2020, 2024, language = "eng")
#' }

plot_selic_rate <- function(data,
                            language = "eng") {

  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("The 'ggplot2' package is required. Install it with install.packages('ggplot2').")
  }

  # Verifica se as colunas necessárias existem
  required_cols <- if (language == "eng") c("date", "rate") else c("data", "taxa")

  missing_cols <- setdiff(required_cols, names(data))
  if (length(missing_cols) > 0) {
    stop("Dataframe is missing required columns: ", paste(missing_cols, collapse = ", "))
  }

  # Define textos conforme o idioma
  if (language == "eng") {
    title <- "Brazil | SELIC Interest Rate (Effective Annual, 252-day basis)"
    y_label <- "SELIC Rate (% p.a.)"
    caption <- "Source: Central Bank of Brazil (SGS 1178)"
    x_var <- "date"
    y_var <- "rate"
  } else {
    title <- "Brasil | Taxa SELIC (Efetiva Anualizada, base 252)"
    y_label <- "Taxa SELIC (% a.a.)"
    caption <- "Fonte: Banco Central do Brasil (SGS 1178)"
    x_var <- "data"
    y_var <- "taxa"
  }

  # Gera o gráfico usando aes() com !!sym() para variáveis dinâmicas
  ggplot2::ggplot(data, ggplot2::aes(x = !!ggplot2::sym(x_var), y = !!ggplot2::sym(y_var))) +
    ggplot2::geom_step(color = "#1f78b4", linewidth = 1) +
    ggplot2::geom_point(color = "#e31a1c", size = 1) +
    ggplot2::scale_x_date(date_breaks = "6 months", date_labels = "%b/%Y") +
    ggplot2::scale_y_continuous(labels = scales::label_number(suffix = "%")) +
    ggplot2::labs(
      title = title,
      x = NULL,
      y = y_label,
      caption = caption
    ) +
    ggplot2::theme_minimal(base_size = 14) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(face = "bold", hjust = 0.5),
      axis.text.x = ggplot2::element_text(angle = 45, hjust = 1)
    )
}
