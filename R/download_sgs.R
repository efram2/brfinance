#' Download a SGS time series from the Brazilian Central Bank
#'
#' Internal helper function to download and format time series
#' data from the Central Bank of Brazil (SGS API).
#'
#' @param series_id Numeric. SGS series ID.
#' @param start_date Optional start date ("YYYY-MM-DD").
#' @param end_date Optional end date ("YYYY-MM-DD").
#'
#' @return A data.frame with columns:
#' \describe{
#'   \item{date}{Reference date.}
#'   \item{value}{Series value.}
#' }
#'
#' @keywords internal

.get_sgs_series <- function(series_id,
                            start_date = NULL,
                            end_date = NULL) {

  # 1. Normalize dates first
  start_date_norm <- .normalize_date(start_date, is_start = TRUE)
  end_date_norm   <- .normalize_date(end_date, is_start = FALSE)

  # 2. Strategy 1: Try with date filters (ONLY if BOTH dates are provided)
  if (!is.null(start_date_norm) && !is.null(end_date_norm)) {
    url_with_dates <- sprintf(
      "https://api.bcb.gov.br/dados/serie/bcdata.sgs.%s/dados?formato=json&dataInicial=%s&dataFinal=%s",
      series_id,
      format(start_date_norm, "%d/%m/%Y"),
      format(end_date_norm, "%d/%m/%Y")
    )

    # Attempt download WITH dates, but suppress the 404 warning
    data <- suppressWarnings(
      tryCatch({
        temp_data <- jsonlite::fromJSON(url_with_dates)
        # Check if we got valid data back (not an empty list/df)
        if (length(temp_data) > 0 && nrow(temp_data) > 0) {
          message(sprintf("Series %s downloaded successfully using date filters.", series_id))
          return(temp_data) # Exit early, success!
        }
        # If data is empty, trigger fallback
        stop("No data returned with filters")
      }, error = function(e) {
        # Silently return NULL to trigger fallback to Strategy 2
        return(NULL)
      })
    )

    # If 'data' is not NULL, the function has already returned it above.
    # If we are here, it means Strategy 1 failed and 'data' is NULL.
  }

  # 3. Strategy 2: Download the FULL series (no date filters in URL)
  message(sprintf("Downloading full SGS series %s from Brazilian Central Bank...", series_id))

  url_full <- sprintf(
    "https://api.bcb.gov.br/dados/serie/bcdata.sgs.%s/dados?formato=json",
    series_id
  )

  data <- tryCatch({
    jsonlite::fromJSON(url_full)
  }, error = function(e) {
    stop(sprintf("Error downloading series %s: %s", series_id, e$message), call. = FALSE)
  })

  # 4. Process the data
  data <- data |>
    dplyr::mutate(
      data = as.Date(data, format = "%d/%m/%Y"),
      valor = as.numeric(valor)
    ) |>
    dplyr::arrange(data)

  # 5. Apply date filters LOCALLY if they were requested
  if (!is.null(start_date_norm)) {
    data <- dplyr::filter(data, data >= start_date_norm)
  }
  if (!is.null(end_date_norm)) {
    data <- dplyr::filter(data, data <= end_date_norm)
  }

  # 6. Check if any data remains
  if (nrow(data) == 0) {
    warning(sprintf("Series %s has no data for the requested period.", series_id), call. = FALSE)
    return(data.frame(data = as.Date(character()), valor = numeric()))
  }

  return(data)
}

# NORMALIZAÇÃO DE DATAS

.normalize_date <- function(x, is_start = TRUE) {

  # 1. Se for NULL, define valor padrão
  if (is.null(x)) {
    return(Sys.Date())
  }

  # Converte para string (segurança)
  x <- as.character(x)

  # 2. Se vier só ano: "2000"
  if (nchar(x) == 4) {
    if (is_start) {
      return(as.Date(paste0(x, "-01-01")))
    } else {
      return(as.Date(paste0(x, "-12-31")))
    }
  }

  # 3. Se vier ano-mês: "2000-02"
  if (nchar(x) == 7) {
    if (is_start) {
      return(as.Date(paste0(x, "-01")))
    } else {
      # Último dia do mês (solução segura)
      ano_mes <- as.Date(paste0(x, "-01"))
      library(lubridate)
      return(rollback(ano_mes + months(1)))

      # Alternativa SEM lubridate:
      # ano <- as.integer(substr(x, 1, 4))
      # mes <- as.integer(substr(x, 6, 7))
      # ultimo_dia <- ifelse(mes == 2,
      #                      28 + as.integer((ano %% 4 == 0 & ano %% 100 != 0) | (ano %% 400 == 0)),
      #                      ifelse(mes %in% c(4, 6, 9, 11), 30, 31))
      # return(as.Date(paste0(x, "-", ultimo_dia)))
    }
  }

  # 4. Se já veio completo: "2000-02-15"
  tryCatch(
    as.Date(x),
    error = function(e) {
      stop("Data '", x, "' em formato inválido. Use: NULL, YYYY, YYYY-MM ou YYYY-MM-DD", call. = FALSE)
    }
  )
}
