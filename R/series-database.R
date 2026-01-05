utils::globalVariables("br_available_series")

# -------------------------------------------------------------------
# Dataset documentation
# -------------------------------------------------------------------

#' Brazilian Economic Series Database
#'
#' A comprehensive database of Brazilian economic and financial time series
#' available through the Central Bank of Brazil's SGS system.
#'
#' @docType data
#'
#' @format A tibble with multiple rows and the following columns:
#' \describe{
#'   \item{series_id}{SGS code from Central Bank of Brazil}
#'   \item{source}{Data source}
#'   \item{source_system}{Source system}
#'   \item{short_name}{Short name of the series}
#'   \item{long_name_pt}{Full name in Portuguese}
#'   \item{long_name_en}{Full name in English}
#'   \item{description_pt}{Description in Portuguese}
#'   \item{description_en}{Description in English}
#'   \item{category_pt}{Category in Portuguese}
#'   \item{category_en}{Category in English}
#'   \item{sub_category_pt}{Sub-category in Portuguese}
#'   \item{sub_category_en}{Sub-category in English}
#'   \item{frequency}{Data frequency}
#'   \item{unit}{Measurement unit}
#'   \item{seasonally_adjusted}{Logical}
#'   \item{start_date}{Series start date}
#'   \item{end_date}{Series end date}
#'   \item{default_transform}{Suggested transformation}
#'   \item{suggested_scale}{Suggested visualization scale}
#'   \item{notes_pt}{Notes in Portuguese}
#'   \item{notes_en}{Notes in English}
#' }
#'
#' @source Central Bank of Brazil — SGS
#'
#' @examples
#' br_available_series
#'
#' br_available_series[br_available_series$series_id == "433", ]
#'
#' br_available_series[br_available_series$series_id == "433", ]
"br_available_series"


# -------------------------------------------------------------------
# Browse available series
# -------------------------------------------------------------------

#' Browse Available Economic Series
#'
#' Displays a searchable table of available Brazilian economic series.
#'
#' @param category Filter by category (optional)
#' @param sub_category Filter by sub-category (optional)
#' @param source Filter by source (optional)
#' @param frequency Filter by frequency (optional)
#' @param search_text Text search across all columns (optional)
#' @param language Language for returned labels. Either \code{"pt"} or \code{"en"}.
#'
#' @return A tibble with available series matching the criteria
#'
#' @examples
#' browse_series()
#' browse_series(category = "Macroeconomic")
#' browse_series(search_text = "inflação")
#'
#' @export
browse_series <- function(category = NULL,
                          sub_category = NULL,
                          source = NULL,
                          frequency = NULL,
                          search_text = NULL,
                          language = c("pt", "en")) {

  language <- match.arg(language)

  data <- get("br_available_series", envir = asNamespace("brfinance"))

  # Mapeamento de colunas por idioma
  long_name_col    <- paste0("long_name_", language)
  category_col     <- paste0("category_", language)
  sub_category_col <- paste0("sub_category_", language)

  if (!is.null(category)) {
    data <- data[data[[category_col]] == category, , drop = FALSE]
  }

  if (!is.null(sub_category)) {
    data <- data[data[[sub_category_col]] == sub_category, , drop = FALSE]
  }

  if (!is.null(source)) {
    data <- data[data$source == source, , drop = FALSE]
  }

  if (!is.null(frequency)) {
    data <- data[data$frequency == frequency, , drop = FALSE]
  }

  if (!is.null(search_text)) {
    search_text <- tolower(search_text)

    matches <- apply(
      as.data.frame(data),
      1,
      function(row) {
        any(grepl(search_text, tolower(as.character(row)), fixed = TRUE))
      }
    )

    data <- data[matches, , drop = FALSE]
  }

  # Colunas finais (neutras)
  out <- data.frame(
    series_id    = data$series_id,
    short_name   = data$short_name,
    long_name    = data[[long_name_col]],
    category     = data[[category_col]],
    sub_category = data[[sub_category_col]],
    frequency    = data$frequency,
    unit         = data$unit,
    start_date   = data$start_date,
    stringsAsFactors = FALSE
  )

  out[order(out$short_name), ]
}

# -------------------------------------------------------------------
# Series information
# -------------------------------------------------------------------

#' Get Series Information
#'
#' Returns detailed metadata about a specific economic series.
#'
#' @param series_id The series ID (SGS code)
#' @param field Specific field to return (optional)
#' @param language Language for returned labels. Either \code{"pt"} or \code{"en"}.
#'
#' @return A list with series metadata or a single value
#'
#' @examples
#' get_series_info("433")
#' get_series_info("433", field = "description", language = "en")
#'
#' @export
get_series_info <- function(series_id,
                            field = NULL,
                            language = c("pt", "en")) {

  language <- match.arg(language)

  data <- get("br_available_series", envir = asNamespace("brfinance"))

  if (!series_id %in% data$series_id) {
    stop(
      "Series ID not found. Use browse_series() to see available series.",
      call. = FALSE
    )
  }

  info <- data[data$series_id == series_id, , drop = FALSE]

  # Mapeamento neutro → bilingue
  field_map <- c(
    long_name    = paste0("long_name_", language),
    description  = paste0("description_", language),
    category     = paste0("category_", language),
    sub_category = paste0("sub_category_", language),
    notes        = paste0("notes_", language)
  )

  if (!is.null(field)) {
    if (field %in% names(field_map)) {
      return(info[[field_map[field]]][[1]])
    }

    if (!field %in% names(info)) {
      stop(
        "Field '", field, "' not available.",
        call. = FALSE
      )
    }

    return(info[[field]][[1]])
  }

  # Retorno completo, já normalizado
  list(
    series_id           = info$series_id,
    source              = info$source,
    source_system       = info$source_system,
    short_name          = info$short_name,
    long_name           = info[[paste0("long_name_", language)]],
    description         = info[[paste0("description_", language)]],
    category            = info[[paste0("category_", language)]],
    sub_category        = info[[paste0("sub_category_", language)]],
    frequency           = info$frequency,
    unit                = info$unit,
    seasonally_adjusted = info$seasonally_adjusted,
    start_date          = info$start_date,
    end_date            = info$end_date,
    default_transform   = info$default_transform,
    suggested_scale     = info$suggested_scale,
    notes               = info[[paste0("notes_", language)]]
  )
}
