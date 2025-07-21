#' Visualiza a taxa Selic diária em um gráfico de linha
#'
#' Esta função baixa dados da taxa Selic (código 1178 no SGS do Banco Central)
#' e retorna um gráfico de linha usando `ggplot2`.
#'
#' @param inicio Data inicial no formato "yyyy-mm-dd"
#' @param fim Data final no formato "yyyy-mm-dd"
#'
#' @return Um gráfico (`ggplot`) da taxa Selic no período escolhido
#' @export
#'
#' @examples
#' \dontrun{
#' plot_selic("2023-01-01", "2024-01-01")
#' }

plot_selic <- function(inicio, fim) {
  url <- paste0(
    "https://api.bcb.gov.br/dados/serie/bcdata.sgs.432/dados?",
    "formato=json&dataInicial=", format(as.Date(inicio), "%d/%m/%Y"),
    "&dataFinal=", format(as.Date(fim), "%d/%m/%Y")
  )

  dados <- httr2::request(url) |>
    httr2::req_perform() |>
    httr2::resp_body_json()

  df <- dplyr::bind_rows(dados) |>
    dplyr::mutate(
      data = lubridate::dmy(data),
      valor = as.numeric(valor)
    )

  ggplot2::ggplot(df, ggplot2::aes(x = data, y = valor)) +
    ggplot2::geom_step(color = "#1f78b4", linewidth = 1) +
    ggplot2::labs(
      title = "Meta da Taxa Selic definida pelo Copom",
      x = "Data", y = "Taxa (% a.a.)",
      caption = "Fonte: Banco Central do Brasil (SGS 432)"
    ) +
    ggplot2::theme_minimal()
}

