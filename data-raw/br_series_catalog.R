br_available_series <- tibble::tibble(
  series_id = c("433", "1178", "12"),
  source = c("BCB", "BCB", "BCB"),
  source_system = c("SGS", "SGS", "SGS"),
  short_name = c("IPCA", "SELIC", "USD/BRL"),
  long_name = c(
    "Índice Nacional de Preços ao Consumidor Amplo",
    "Taxa Selic Meta",
    "Taxa de câmbio - Livre - Dólar americano (venda)"
  ),
  description = c(
    "Principal índice de inflação ao consumidor no Brasil",
    "Taxa básica de juros definida pelo COPOM",
    "Taxa de câmbio nominal R$/US$ no mercado livre"
  ),
  category = c("Macroeconomic", "Monetary Policy", "External Sector"),
  sub_category = c("Inflation", "Interest Rate", "Exchange Rate"),
  frequency = c("monthly", "daily", "daily"),
  unit = c("percent", "percent", "BRL"),
  seasonally_adjusted = c(FALSE, FALSE, FALSE),
  start_date = as.Date(c("1980-01-01", "1986-03-01", "1994-07-01")),
  end_date = as.Date(c(NA, NA, NA)),
  default_transform = c("pct_change", "none", "log"),
  suggested_scale = c("linear", "linear", "log"),
  notes = c(
    "Used for inflation targeting regime",
    "Target rate, not effective rate",
    "End-of-period value"
  )
)
