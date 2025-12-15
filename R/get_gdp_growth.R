#' Get GDP Growth Rate
#'
#' Downloads quarterly GDP growth data (% change) from BCB/SGS.
#'
#' @param start_date Start date in "YYYY-MM-DD" format. Default is "2000-01-01".
#' @param end_date End date in "YYYY-MM-DD" format. Default is NULL (most recent data).
#' @param language Language for column names: "pt" for Portuguese or "eng" (default) for English.
#' @param labels By default it is TRUE, if you do not want labels use FALSE.
#'
#' @return A data.frame with GDP growth rate.
#'
#' @examples
#' \dontrun{
#'   df <- get_gdp_growth()
#'
#'   # Specific period
#'   df2 <- get_gdp_growth("2015-01-01", "2020-12-01")
#'
#'   # By a specific date (from the beginning until 2000)
#'   df3 <- get_gdp_growth(end_date = "2020-12-01")
#'
#'   # With language in Portuguese
#'   df4 <- get_gdp_growth(language = "pt")
#'
#'   df5 <- get_gdp_growth("2015-01-01", "2020-12-01", language = "pt")
#' }
#'
#' @export
get_gdp_growth <- function(start_date = "2000-01-01",
                           end_date = NULL,
                           language = "eng",
                           labels = TRUE) {


  # Usa a função interna para baixar os dados
  data <- .get_sgs_series(
    series_id = 2010,  # GDP nominal code
    start_date = start_date,
    end_date = end_date
  )

  # Garante que temos as colunas com os nomes corretos
  # A função .get_sgs_series SEMPRE retorna 'data' e 'valor'
  if (!all(c("data", "valor") %in% names(data))) {
    stop("Internal error: expected columns 'data' and 'valor' not found", call. = FALSE)
  }

  # Agora processa os dados
  data <- data |>
    dplyr::arrange(data) |>
    dplyr::mutate(
      gdp_nominal = as.numeric(valor),
      gdp_growth = (gdp_nominal / dplyr::lag(gdp_nominal) - 1) * 100
    ) |>
    dplyr::select(
      date = data,
      gdp_growth,
      gdp_nominal
    )

  # Aplica filtro de data final (já foi aplicado na função interna, mas mantém)
  if (!is.null(end_date)) {
    data <- data |> dplyr::filter(date <= as.Date(end_date))
  }

  # Tradução para português se necessário
  if (tolower(language) == "pt") {
    data <- data |>
      dplyr::rename(
        data_referencia = date,
        crescimento_pib = gdp_growth,
        pib_nominal = gdp_nominal
      )
  }

  # Adiciona labels se solicitado
  if (isTRUE(labels) && requireNamespace("labelled", quietly = TRUE)) {
    if (tolower(language) == "pt") {
      data <- labelled::set_variable_labels(
        data,
        data_referencia = "Trimestre de referência",
        crescimento_pib = "Crescimento do PIB real (%)",
        pib_nominal = "PIB nominal (R$ milhões)"
      )
    } else {
      data <- labelled::set_variable_labels(
        data,
        date = "Reference quarter",
        gdp_growth = "GDP growth rate (%)",
        gdp_nominal = "Nominal GDP (R$ millions)"
      )
    }
  }

  # Remove a coluna gdp_nominal do resultado final (mantém só o crescimento)
  if (tolower(language) == "pt") {
    data <- dplyr::select(data, data_referencia,  )
  } else {
    data <- dplyr::select(data, date, gdp_growth)
  }

  return(data)
}
