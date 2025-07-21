#' Visualiza a taxa Selic diária em um gráfico de linha
#'
#' Esta função baixa dados da taxa Selic (código 1178 no SGS do Banco Central)
#' e retorna um gráfico de linha usando `ggplot2`.
#'
#' @param data_inicial Data inicial no formato "yyyy-mm-dd"
#' @param data_final Data final no formato "yyyy-mm-dd"
#'
#' @return Um gráfico (`ggplot`) da taxa Selic no período escolhido
#' @export
#'
#' @examples
#' \dontrun{
#' plot_selic("2023-01-01", "2024-01-01")
#' }

plot_selic <- function(inicio, fim) {
  # Carregar pacotes
  library(httr2)
  library(jsonlite)
  library(dplyr)
  library(ggplot2)
  library(lubridate)

  # Converter datas para o formato esperado pela API
  data_inicial <- format(as.Date(inicio), "%d/%m/%Y")
  data_final <- format(as.Date(fim), "%d/%m/%Y")

  # Montar URL da API
  url <- paste0(
    "https://api.bcb.gov.br/dados/serie/bcdata.sgs.11/dados?",
    "formato=json&dataInicial=", data_inicial,
    "&dataFinal=", data_final
  )

  # Requisição
  resp <- request(url) |> req_perform()
  dados <- resp |> resp_body_json()

  # Transformar em data frame
  selic_df <- as.data.frame(dados) |>
    mutate(
      data = dmy(data),
      valor = as.numeric(valor)
    )

  # Plot
  ggplot(selic_df, aes(x = data, y = valor)) +
    geom_line(color = "#1f78b4", size = 1.2) +
    labs(
      title = "Taxa Selic Diária",
      x = "Data",
      y = "Taxa (%)"
    ) +
    theme_minimal()
}

