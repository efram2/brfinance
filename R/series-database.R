# R/series-database.R

#' Brazilian Economic Series Database
#'
#' A comprehensive database of Brazilian economic and financial time series
#' available through the Central Bank of Brazil's SGS system.
#'
#' @format A tibble with 9 rows and 16 columns:
#' \describe{
#'   \item{series_id}{SGS code from Central Bank of Brazil}
#'   \item{source}{Data source ("BCB" for Central Bank of Brazil)}
#'   \item{source_system}{Source system ("SGS" for Time Series Management System)}
#'   \item{short_name}{Short name/abbreviation of the series}
#'   \item{long_name}{Full descriptive name of the series}
#'   \item{description}{Detailed description of what the series measures}
#'   \item{category}{Main category (e.g., "Macroeconomic")}
#'   \item{sub_category}{Sub-category (e.g., "Inflation", "Exchange Rate")}
#'   \item{frequency}{Data frequency ("daily", "monthly")}
#'   \item{unit}{Measurement unit ("percent", "BRL")}
#'   \item{seasonally_adjusted}{Logical indicating if series is seasonally adjusted}
#'   \item{start_date}{Series start date}
#'   \item{end_date}{Series end date (NA if ongoing)}
#'   \item{default_transform}{Suggested default transformation for analysis}
#'   \item{suggested_scale}{Suggested scale for visualization}
#'   \item{notes}{Additional notes and comments}
#' }
#'
#' @source Central Bank of Brazil - Time Series Management System (SGS)
#'
#' @examples
#' # View the entire database
#' br_available_series
#'
#' # Filter for inflation series
#' dplyr::filter(br_available_series, sub_category == "Inflation")
#'
#' # Find series by ID
#' br_available_series[br_available_series$series_id == "433", ]
#'
"br_available_series"

#' Browse Available Economic Series
#'
#' Displays a searchable table of available economic and financial series in Brazil.
#'
#' @param category Filter by category (optional)
#' @param sub_category Filter by sub-category (optional)
#' @param source Filter by source (optional)
#' @param frequency Filter by frequency (optional)
#' @param search_text Text search across all columns (optional)
#'
#' @return A tibble with available series matching the criteria
#'
#' @examples
#' # View all available series
#' browse_series()
#'
#' # Filter by category
#' browse_series(category = "Macroeconomic")
#'
#' # Search for inflation series
#' browse_series(search_text = "inflação")
#'
#' @export
browse_series <- function(category = NULL, sub_category = NULL,
                          source = NULL, frequency = NULL, search_text = NULL) {
  # Verificar se o pacote está carregado
  if (!exists("br_available_series")) {
    data("br_available_series", package = "brfinance")
  }

  data <- br_available_series

  # Aplicar filtros
  if (!is.null(category)) {
    data <- data[data$category == category, ]
  }

  if (!is.null(sub_category)) {
    data <- data[data$sub_category == sub_category, ]
  }

  if (!is.null(source)) {
    data <- data[data$source == source, ]
  }

  if (!is.null(frequency)) {
    data <- data[data$frequency == frequency, ]
  }

  # Busca textual
  if (!is.null(search_text)) {
    search_text <- tolower(search_text)
    matches <- apply(data, 1, function(row) {
      any(grepl(search_text, tolower(row)))
    })
    data <- data[matches, ]
  }

  # Ordenar por short_name
  data <- data[order(data$short_name), ]

  # Retornar apenas colunas mais importantes para visualização
  cols_to_show <- c("series_id", "short_name", "long_name", "category",
                    "sub_category", "frequency", "unit", "start_date")

  return(data[, cols_to_show])
}

#' Get Series Information
#'
#' Returns detailed information about a specific economic series.
#'
#' @param series_id The series ID (SGS code from BCB)
#' @param field Specific field to return (optional). If NULL, returns all information.
#'
#' @return A list or character with series information
#'
#' @examples
#' # Get all information about IPCA
#' get_series_info("433")
#'
#' # Get only the description
#' get_series_info("433", field = "description")
#'
#' @export
get_series_info <- function(series_id, field = NULL) {
  # Verificar se o pacote está carregado
  if (!exists("br_available_series")) {
    data("br_available_series", package = "brfinance")
  }

  data <- br_available_series

  if (!series_id %in% data$series_id) {
    stop("Series ID not found in database. Use browse_series() to see available series.")
  }

  info <- data[data$series_id == series_id, ]

  if (nrow(info) == 0) {
    stop("Series ID not found: ", series_id)
  }

  if (!is.null(field)) {
    if (!field %in% names(info)) {
      stop("Field '", field, "' not available. Available fields: ",
           paste(names(info), collapse = ", "))
    }
    return(info[[field]])
  }

  return(as.list(info))
}
