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

  # === PARAMETER VALIDATION ===
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("The 'ggplot2' package is required. Install it with install.packages('ggplot2').")
  }

  if (!requireNamespace("dplyr", quietly = TRUE)) {
    stop("The 'dplyr' package is required. Install it with install.packages('dplyr').")
  }

  if (!requireNamespace("tidyr", quietly = TRUE)) {
    stop("The 'tidyr' package is required. Install it with install.packages('tidyr').")
  }

  if (!is.data.frame(data)) {
    stop("'data' must be a data frame or tibble", call. = FALSE)
  }

  if (nrow(data) == 0) {
    stop("'data' must have at least one row", call. = FALSE)
  }

  # Validate 'language' parameter
  if (!is.character(language) || length(language) != 1) {
    stop("'language' must be a single character string ('eng' or 'pt')", call. = FALSE)
  }

  # === FUNCTION BODY ===
  # Define texts based on language
  if (language == "eng") {
    .plot_time_series(
      data = data,
      x_var = "date",
      y_var = "rate",
      plot_type = "line",
      title = "Brazil | Unemployment Rate (Continuous PNAD)",
      y_label = "Unemployment Rate (%)",
      caption = "Source: IBGE - SIDRA (Table 6381)",
      y_suffix = "%",
      color = "#2c3e50",
      point_color = "#e74c3c",
      show_points = TRUE
    )
  } else {
    .plot_time_series(
      data = data,
      x_var = "data",
      y_var = "taxa",
      plot_type = "line",
      title = "Brasil | Taxa de Desemprego (PNAD Continua)",
      y_label = "Taxa de desemprego (%)",
      caption = "Fonte: IBGE - SIDRA (Tabela 6381)",
      y_suffix = "%",
      color = "#2c3e50",
      point_color = "#e74c3c",
      show_points = TRUE
    )
  }
}
