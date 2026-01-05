# Lista completa de séries econômicas e financeiras do Brasil
# data-raw/create_series_database.R
#' Create br_available_series dataset
#'
#' This script creates the comprehensive dataset of Brazilian economic series
#' that is included in the brfinance package.

library(tibble)
library(dplyr)

# Primeiro, vamos criar listas menores para testar
br_available_series <- tibble::tibble(
  series_id = c("433", "1178", "12", "4390", "4391", "4392", "4393", "4394", "4395"),
  source = rep("BCB", 9),
  source_system = rep("SGS", 9),
  short_name = c("IPCA", "SELIC", "USD_BRL", "IGP-M", "IGP-DI", "IPA-M", "IPA-DI", "IPC-M", "IPC-DI"),
  long_name = c(
    "Índice Nacional de Preços ao Consumidor Amplo",
    "Taxa Selic Meta",
    "Taxa de câmbio - Livre - Dólar americano (venda)",
    "Índice Geral de Preços - Mercado",
    "Índice Geral de Preços - Disponibilidade Interna",
    "Índice de Preços ao Produtor Amplo - Mercado",
    "Índice de Preços ao Produtor Amplo - Disponibilidade Interna",
    "Índice de Preços ao Consumidor - Mercado",
    "Índice de Preços ao Consumidor - Disponibilidade Interna"
  ),
  description = c(
    "Principal índice de inflação ao consumidor no Brasil",
    "Taxa básica de juros definida pelo COPOM",
    "Taxa de câmbio nominal R$/US$ no mercado livre",
    "Índice geral de preços medido pelo FGV",
    "Índice geral de preços com base na disponibilidade interna",
    "Índice de preços ao produtor para o mercado",
    "Índice de preços ao produtor para disponibilidade interna",
    "Índice de preços ao consumidor para o mercado",
    "Índice de preços ao consumidor para disponibilidade interna"
  ),
  category = rep("Macroeconomic", 9),
  sub_category = c(rep("Inflation", 8), "Inflation"),
  frequency = rep("monthly", 9),
  unit = rep("percent", 9),
  seasonally_adjusted = rep(FALSE, 9),
  start_date = as.Date(rep("1980-01-01", 9)),
  end_date = as.Date(rep(NA, 9)),
  default_transform = c("pct_change", "none", "log", rep("pct_change", 6)),
  suggested_scale = rep("linear", 9),
  notes = c(
    "Used for inflation targeting regime",
    "Target rate, not effective rate",
    "End-of-period value",
    "FGV price index",
    "FGV price index for domestic availability",
    "Producer price index for market",
    "Producer price index for domestic availability",
    "Consumer price index for market",
    "Consumer price index for domestic availability"
  )
)


# Salvar como RDA na pasta data/
usethis::use_data(br_available_series, overwrite = TRUE)

# Criar também como CSV para referência
readr::write_csv(br_available_series, "data-raw/series_data.csv")

# Criar documentação Roxygen
usethis::use_r("series-database")

