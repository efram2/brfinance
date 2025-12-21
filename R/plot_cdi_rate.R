#' Plot Brazilian CDI rate
#'
#' Generates a time series plot of the CDI (Certificado de Depósito Interbancário) rate.
#' The CDI is the benchmark interest rate for interbank deposits in Brazil and serves
#' as a reference for many fixed income investments.
#'
#' @param data Tibble returned by `get_cdi_rate()`
#' @param language Language for titles and labels: "pt" (Portuguese) or "eng" (English).
#'
#' @return A `ggplot2` object showing the CDI rate over time.
#' @export
#'
#' @examples
#' \dontrun{
#' # Example 1: English version
#' cdi_data <- get_cdi_rate(2020, 2024)
#' cdi_plot <- plot_cdi_rate(cdi_data)
#' print(cdi_plot)
#'
#' # Example 2: Portuguese version
#' dados_cdi <- get_cdi_rate(2020, 2024, language = "pt")
#' grafico_cdi <- plot_cdi_rate(dados_cdi, language = "pt")
#' print(grafico_cdi)
#' }

plot_cdi_rate <- function(data,
                          language = "eng") {

  # === PARAMETER VALIDATION ===

  # Validate 'data' parameter
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

  language <- tolower(language)
  if (!language %in% c("eng", "pt")) {
    stop("'language' must be either 'eng' (English) or 'pt' (Portuguese)", call. = FALSE)
  }

  # === FUNCTION BODY ===

  # Declare global variables for dplyr operations
  value <- taxa_cdi <- data_referencia <- rate <- NULL

  # Define texts based on language
  if (language == "eng") {
    # Check column names for English
    if ("taxa_cdi" %in% names(data) && !"rate" %in% names(data)) {
      data <- dplyr::rename(data, rate = taxa_cdi)
    }
    if ("data_referencia" %in% names(data) && !"date" %in% names(data)) {
      data <- dplyr::rename(data, date = data_referencia)
    }

    # Use internal plotting function
    .plot_time_series(
      data = data,
      x_var = "date",
      y_var = "cdi_rate",
      plot_type = "line",
      title = "Brazil | CDI Interest Rate",
      y_label = "CDI Rate (% p.a.)",
      caption = "Source: Central Bank of Brazil",
      y_suffix = "%",
      color = "#3498db",
      point_color = "#e74c3c",
      show_points = TRUE,
      date_breaks = "6 months"
    )
  } else {
    # Check column names for Portuguese
    if ("cdi_rate" %in% names(data) && !"taxa" %in% names(data)) {
      data <- dplyr::rename(data, taxa = rate)
    }
    if ("date" %in% names(data) && !"data" %in% names(data)) {
      data <- dplyr::rename(data, data = date)
    }

    # Use internal plotting function
    .plot_time_series(
      data = data,
      x_var = "data_referencia",
      y_var = "taxa_cdi",
      plot_type = "line",
      title = "Brasil | Taxa CDI",
      y_label = "Taxa CDI (% a.a.)",
      caption = "Fonte: Banco Central do Brasil",
      y_suffix = "%",
      color = "#3498db",
      point_color = "#e74c3c",
      show_points = TRUE,
      date_breaks = "6 meses"
    )
  }
}
