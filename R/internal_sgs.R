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

  # Validação básica do series_id
  if (!is.numeric(series_id) || length(series_id) != 1) {
    stop("series_id deve ser um número único", call. = FALSE)
  }

  start_date <- .normalize_date(start_date, is_start = TRUE)
  end_date   <- .normalize_date(end_date, is_start = FALSE)

  # Verifica ordem das datas
  if (!is.null(start_date) && !is.null(end_date) && start_date > end_date) {
    stop("start_date não pode ser posterior a end_date", call. = FALSE)
  }

  # Se não passar datas, define intervalo bem amplo
  if (is.null(start_date)) start_date <- as.Date("2000-01-01")
  if (is.null(end_date))   end_date   <- Sys.Date()

  url <- sprintf(
    paste0(
      "https://api.bcb.gov.br/dados/serie/bcdata.sgs.%s/dados?",
      "formato=json&dataInicial=%s&dataFinal=%s"
    ),
    series_id,
    format(start_date, "%d/%m/%Y"),
    format(end_date, "%d/%m/%Y")
  )

  tryCatch({
    data <- jsonlite::fromJSON(url)

    # Verifica se a série existe/dados retornados
    if (length(data) == 0) {
      warning(
        sprintf("Série %s não retornou dados no período especificado", series_id),
        call. = FALSE
      )
      return(data.frame(date = as.Date(character()), value = numeric()))
    }

    data <- data |>
      dplyr::mutate(
        data = as.Date(data, format = "%d/%m/%Y"),
        valor = as.numeric(valor)
      )

    return(data)

  }, error = function(e) {
    stop(
      sprintf("Erro ao baixar série %s: %s", series_id, e$message),
      call. = FALSE
    )
  })
}


# Função normalização de datas

.normalize_date <- function(x, is_start = TRUE) {

  if (is.null(x)) return(NULL)

  # Converte para string se não for
  x <- as.character(x)

  # Se vier só ano: "2000"
  if (nchar(x) == 4) {
    if (is_start) {
      return(as.Date(paste0(x, "-01-01")))
    } else {
      return(as.Date(paste0(x, "-12-31")))
    }
  }

  # Se vier ano-mês: "2000-02"
  if (nchar(x) == 7) {
    if (is_start) {
      return(as.Date(paste0(x, "-01")))
    } else {
      return(as.Date(paste0(x, "-28"))) # seguro para API
    }
  }

  # Se já veio completo
  tryCatch(
    as.Date(x),
    error = function(e) {
      stop("Data '", x, "' em formato inválido. Use YYYY, YYYY-MM ou YYYY-MM-DD", call. = FALSE)
    }
  )
}
