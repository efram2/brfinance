#' Plot Brazilian exchange rate (USD/BRL)
#'
#' Generates a time series plot of the USD/BRL exchange rate using data from `get_exchange_rate()`.
#' Shows the commercial exchange rate for US Dollar to Brazilian Real.
#'
#' @param data Tibble returned by `get_exchange_rate()`
#' @param language Language for titles and labels: "pt" (Portuguese) or "eng" (English).
#'
#' @return A `ggplot2` object showing the exchange rate over time.
#' @export
#'
#' @examples
#' \dontrun{
#' # Example 1: English version
#' exchange_data <- get_exchange_rate("2023-01-01", "2023-12-31")
#' exchange_plot <- plot_exchange_rate(exchange_data)
#' print(exchange_plot)
#'
#' # Example 2: Portuguese version
#' dados_cambio <- get_exchange_rate("2023-01-01", "2023-12-31", language = "pt")
#' grafico_cambio <- plot_exchange_rate(dados_cambio, language = "pt")
#' print(grafico_cambio)
#' }

plot_exchange_rate <- function(data,
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

  # Define texts based on language
  if (language == "eng") {
    # Check column names for English
    if ("cotacao" %in% names(data) && !"rate" %in% names(data)) {
      data <- dplyr::rename(data, rate = cotacao)
    }
    if ("data" %in% names(data) && !"date" %in% names(data)) {
      data <- dplyr::rename(data, date = data)
    }

    # Use internal plotting function
    .plot_time_series(
      data = data,
      x_var = "date",
      y_var = "rate",
      plot_type = "line",
      title = "Brazil | Exchange Rate (USD/BRL)",
      y_label = "Exchange Rate (R$/US$)",
      caption = "Source: Central Bank of Brazil",
      y_suffix = NULL,  # No suffix for exchange rate
      color = "#2c3e50",
      point_color = "#e74c3c",
      show_points = TRUE,
      date_breaks = "3 months"  # More frequent breaks for exchange rates
    )
  } else {
    # Check column names for Portuguese
    if ("date" %in% names(data) && !"data" %in% names(data)) {
      data <- dplyr::rename(data, data = date)
    }
    if ("rate" %in% names(data) && !"taxa" %in% names(data)) {
      data <- dplyr::rename(data, taxa = rate)
    }

    # Use internal plotting function
    .plot_time_series(
      data = data,
      x_var = "data",
      y_var = "taxa",
      plot_type = "line",
      title = "Brasil | Taxa de Câmbio (USD/BRL)",
      y_label = "Taxa de Câmbio (R$/US$)",
      caption = "Fonte: Banco Central do Brasil",
      y_suffix = NULL,  # No suffix for exchange rate
      color = "#2c3e50",
      point_color = "#e74c3c",
      show_points = TRUE,
      date_breaks = "3 meses"  # Portuguese version
    )
  }
}
