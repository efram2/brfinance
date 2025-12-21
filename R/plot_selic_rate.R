#' Plot Brazilian SELIC rate (annualized, base 252)
#'
#' Generates a time series plot of the SELIC interest rate using data from `get_selic()`.
#' The SELIC rate ("Sistema Especial de Liquidação e de Custódia") represents the
#' effective annualized rate (252-business-day basis) for overnight interbank loans
#' and is the main instrument of Brazil’s monetary policy.
#'
#' @param data Tibble returned by `get_selic_rate()`
#' @param language Language for titles and labels: "pt" (Portuguese) or "eng" (English).
#'
#' @return A `ggplot2` object showing the SELIC rate over time.
#' @export
#'
#' @examples
#' \dontrun{
#' # Example 1: English version
#' selic_data <- get_selic_rate(2020, 2024)
#' selic_plot <- plot_selic_rate(selic_data)
#' print(selic_plot)
#'
#' # Example 2: Portuguese version
#' dados_selic <- get_selic_rate(2020, 2024, language = "pt")
#' grafico_selic <- plot_selic_rate(dados_selic, language = "pt")
#' print(grafico_selic)
#' }

plot_selic_rate <- function(data,
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

  # === FUNCTION BODY ===
  # Validate 'language' parameter
  if (!is.character(language) || length(language) != 1) {
    stop("'language' must be a single character string ('eng' or 'pt')", call. = FALSE)
  }

  # Declare global variables for dplyr operations
  value <- selic_rate <- data_referencia <- taxa_selic <- NULL

  # === COMPATIBILITY LAYER ===
  if (language == "pt") {
    if ("data_referencia" %in% names(data) && "taxa_selic" %in% names(data)) {
      data <- data |>
        dplyr::rename(data = data_referencia, taxa = taxa_selic)
    }
  } else {
    if ("selic_rate" %in% names(data)) {
      data <- data |>
        dplyr::rename(rate = selic_rate)
    }
  }

  # Define texts based on language
  if (language == "eng") {
    .plot_time_series(
      data = data,
      x_var = "date",
      y_var = "rate",
      plot_type = "step",
      title = "Brazil | SELIC Interest Rate (Effective Annual, 252-day basis)",
      y_label = "SELIC Rate (% p.a.)",
      caption = "Source: Central Bank of Brazil (SGS 1178)",
      y_suffix = "%",
      color = "#1f78b4",
      point_color = "#e31a1c",
      show_points = TRUE
    )
  } else {
    .plot_time_series(
      data = data,
      x_var = "data",
      y_var = "taxa",
      plot_type = "step",
      title = "Brasil | Taxa SELIC (Efetiva Anualizada, base 252)",
      y_label = "Taxa SELIC (% a.a.)",
      caption = "Fonte: Banco Central do Brasil (SGS 1178)",
      y_suffix = "%",
      color = "#1f78b4",
      point_color = "#e31a1c",
      show_points = TRUE
    )
  }
}
