# -------------------------------------------------------------------
# Shared configuration for all plot_*() functions
# -------------------------------------------------------------------
# Instead of five near-identical files (one per series) duplicating
# validation + title/label logic, every series' metadata lives here and
# a single internal engine (.plot_named_series) does the rendering.
# Colors follow a muted, "elegant financial" palette rather than
# saturated terminal-style hues: a deep navy blue for benchmark rates
# (SELIC, CDI, exchange rate, Ibovespa) and a muted brick red for
# cost/risk indicators (inflation, unemployment) -- with the opposite
# tone used for point markers, which only render at all on sparse
# (<=60 row) series; see .plot_time_series()'s "auto" density rule.

.BRFINANCE_MARKET_BLUE <- "#1B4F72"
.BRFINANCE_MARKET_RED  <- "#A6303C"

.brfinance_plot_config <- list(
  cdi = list(
    plot_type = "line",
    date_breaks = "6 months",
    y_suffix = "%",
    color = .BRFINANCE_MARKET_BLUE,
    point_color = .BRFINANCE_MARKET_RED,
    title_en = "Brazil | CDI Rate",
    title_pt = "Brasil | Taxa CDI",
    y_label_en = "Daily CDI rate (% per day)",
    y_label_pt = "Taxa CDI diaria (% ao dia)",
    caption_en = "Source: Central Bank of Brazil (SGS 12)",
    caption_pt = "Fonte: Banco Central do Brasil (SGS 12)"
  ),
  selic = list(
    y_var = "value_annualized",
    plot_type = "step",
    date_breaks = "6 months",
    y_suffix = "%",
    color = .BRFINANCE_MARKET_BLUE,
    point_color = .BRFINANCE_MARKET_RED,
    title_en = "Brazil | SELIC Interest Rate (Annualized, 252-day basis)",
    title_pt = "Brasil | Taxa SELIC (Anualizada, base 252)",
    y_label_en = "SELIC Rate (% p.a.)",
    y_label_pt = "Taxa SELIC (% a.a.)",
    caption_en = "Source: Central Bank of Brazil (SGS 11), annualized locally",
    caption_pt = "Fonte: Banco Central do Brasil (SGS 11), anualizada localmente"
  ),
  exchange = list(
    plot_type = "line",
    date_breaks = "3 months",
    y_suffix = NULL,
    color = .BRFINANCE_MARKET_BLUE,
    point_color = .BRFINANCE_MARKET_RED,
    title_en = "Brazil | Exchange Rate (USD/BRL)",
    title_pt = "Brasil | Taxa de Cambio (USD/BRL)",
    y_label_en = "Exchange Rate (R$/US$)",
    y_label_pt = "Taxa de cambio (R$/US$)",
    caption_en = "Source: Central Bank of Brazil",
    caption_pt = "Fonte: Banco Central do Brasil"
  ),
  inflation = list(
    plot_type = "line",
    date_breaks = "6 months",
    y_suffix = "%",
    color = .BRFINANCE_MARKET_RED,
    point_color = .BRFINANCE_MARKET_BLUE,
    title_en = "Brazil | Inflation Rate (IPCA)",
    title_pt = "Brasil | Inflacao (IPCA)",
    y_label_en = "Monthly inflation (%)",
    y_label_pt = "Inflacao mensal (%)",
    caption_en = "Source: IBGE / Central Bank of Brazil (SGS 433)",
    caption_pt = "Fonte: IBGE / Banco Central do Brasil (SGS 433)"
  ),
  unemployment = list(
    plot_type = "line",
    date_breaks = "1 year",
    y_suffix = "%",
    color = .BRFINANCE_MARKET_RED,
    point_color = .BRFINANCE_MARKET_BLUE,
    title_en = "Brazil | Unemployment Rate (PNAD Continua)",
    title_pt = "Brasil | Taxa de Desemprego (PNAD Continua)",
    y_label_en = "Unemployment Rate (%)",
    y_label_pt = "Taxa de desemprego (%)",
    caption_en = "Source: Brazilian Central Bank (SGS 24369)",
    caption_pt = "Fonte: Banco Central do Brasil (SGS 24369)"
  ),
  ibovespa = list(
    plot_type = "line",
    date_breaks = "3 months",
    y_suffix = NULL,
    color = .BRFINANCE_MARKET_BLUE,
    point_color = .BRFINANCE_MARKET_RED,
    title_en = "Brazil | Ibovespa Index",
    title_pt = "Brasil | Indice Ibovespa",
    y_label_en = "Ibovespa (index points)",
    y_label_pt = "Ibovespa (pontos)",
    caption_en = "Source: Yahoo Finance (^BVSP), via yfR",
    caption_pt = "Fonte: Yahoo Finance (^BVSP), via yfR"
  )
)

# -------------------------------------------------------------------
# Shared engine: validation + dispatch to .plot_time_series()
# -------------------------------------------------------------------

#' @keywords internal
#' @noRd
.plot_named_series <- function(data, series_key, language = "eng") {

  if (!is.data.frame(data)) {
    stop("'data' must be a data frame or tibble", call. = FALSE)
  }

  cfg <- .brfinance_plot_config[[series_key]]

  # Which column to actually plot on the y-axis. Defaults to "value";
  # a series can override this (e.g. SELIC plots "value_annualized", since
  # get_selic_rate() now returns the raw daily rate in "value" and the
  # annualized rate — the one people expect to see on a chart — separately).
  y_var <- if (!is.null(cfg$y_var)) cfg$y_var else "value"

  required_cols <- c("date", y_var)
  missing_cols <- setdiff(required_cols, names(data))

  if (length(missing_cols) > 0) {
    stop(
      paste0(
        "'data' must contain columns: ",
        paste(required_cols, collapse = ", ")
      ),
      call. = FALSE
    )
  }

  if (!is.character(language) || length(language) != 1) {
    stop("'language' must be a single character string ('eng' or 'pt')", call. = FALSE)
  }

  language <- tolower(language)
  if (!language %in% c("eng", "pt")) {
    stop("'language' must be either 'eng' (English) or 'pt' (Portuguese)", call. = FALSE)
  }

  title   <- if (language == "pt") cfg$title_pt   else cfg$title_en
  y_label <- if (language == "pt") cfg$y_label_pt else cfg$y_label_en
  caption <- if (language == "pt") cfg$caption_pt else cfg$caption_en

  .plot_time_series(
    data = data,
    x_var = "date",
    y_var = y_var,
    plot_type = cfg$plot_type,
    title = title,
    y_label = y_label,
    caption = caption,
    y_suffix = cfg$y_suffix,
    color = cfg$color,
    point_color = cfg$point_color,
    show_points = "auto",
    date_breaks = cfg$date_breaks
  )
}

# -------------------------------------------------------------------
# Public plot_*() wrappers — same signatures/exports as before, now
# just a config lookup instead of duplicated logic.
# -------------------------------------------------------------------

#' Plot Brazilian CDI rate
#'
#' Generates a time series plot of the CDI (Certificado de Depósito Interbancário) rate.
#'
#' @param data Tibble returned by `get_cdi_rate()`, with columns `date` and `value`.
#' @param language Language for titles and labels: "pt" (Portuguese) or "eng" (English).
#'
#' @return A `ggplot2` object showing the CDI rate over time.
#'
#' @examples
#' \donttest{
#' cdi_data <- get_cdi_rate("2020", "2024")
#' print(plot_cdi_rate(cdi_data))
#' print(plot_cdi_rate(get_cdi_rate(language = "pt"), language = "pt"))
#' }
#'
#' @export
plot_cdi_rate <- function(data, language = "eng") {
  .plot_named_series(data, "cdi", language)
}

#' Plot Brazilian SELIC rate (annualized, base 252)
#'
#' Generates a time series plot of the SELIC interest rate using data from
#' `get_selic_rate()`. Plots the `value_annualized` column (% p.a.), not the
#' raw daily `value` column.
#'
#' @param data Tibble returned by `get_selic_rate()`.
#' @param language Language for titles and labels: "pt" (Portuguese) or "eng" (English).
#'
#' @return A `ggplot2` object showing the SELIC rate over time.
#'
#' @examples
#' \donttest{
#' selic_data <- get_selic_rate("2020", "2024")
#' print(plot_selic_rate(selic_data))
#' print(plot_selic_rate(get_selic_rate(language = "pt"), language = "pt"))
#' }
#'
#' @export
plot_selic_rate <- function(data, language = "eng") {
  .plot_named_series(data, "selic", language)
}

#' Plot Brazilian exchange rate (USD/BRL)
#'
#' Generates a time series plot of the USD/BRL exchange rate using data from `get_exchange_rate()`.
#'
#' @param data Tibble returned by `get_exchange_rate()`.
#' @param language Language for titles and labels: "pt" (Portuguese) or "eng" (English).
#'
#' @return A `ggplot2` object showing the exchange rate over time.
#'
#' @examples
#' \donttest{
#' exchange_data <- get_exchange_rate("2023-01-01", "2023-12-31")
#' print(plot_exchange_rate(exchange_data))
#'}
#'
#' @export
plot_exchange_rate <- function(data, language = "eng") {
  .plot_named_series(data, "exchange", language)
}

#' Plot Brazilian Inflation Rate (IPCA)
#'
#' Generates a time series plot of Brazil's monthly inflation rate measured
#' by the IPCA (Índice Nacional de Preços ao Consumidor Amplo).
#'
#' @param data Tibble returned by `get_inflation_rate()`, with columns `date` and `value`.
#' @param language Language for titles and labels: "pt" (Portuguese) or "eng" (English).
#'
#' @return A `ggplot2` object showing the monthly inflation rate over time.
#'
#' @examples
#' \donttest{
#' inflation_data <- get_inflation_rate("2020", "2024")
#' print(plot_inflation_rate(inflation_data))
#'}
#'
#' @export
plot_inflation_rate <- function(data, language = "eng") {
  .plot_named_series(data, "inflation", language)
}

#' Plot Brazil's monthly unemployment rate
#'
#' Generates a ggplot2 line chart of Brazil's unemployment rate
#' (PNAD Contínua) using data returned by `get_unemployment()`.
#'
#' @param data Tibble or data.frame returned by `get_unemployment()`.
#'   Must contain columns `date` (Date) and `value` (numeric).
#' @param language Language of plot labels: "eng" (default) or "pt".
#'
#' @return A ggplot2 object.
#'
#' @examples
#' \donttest{
#' unemployment_data <- get_unemployment("2020", "2024")
#' print(plot_unemployment(unemployment_data))
#'}
#'
#' @export
plot_unemployment <- function(data, language = "eng") {
  .plot_named_series(data, "unemployment", language)
}

#' Plot Ibovespa Index
#'
#' Generates a time series plot of the Ibovespa index using data from `get_ibovespa()`.
#'
#' @param data Tibble returned by `get_ibovespa()`, with columns `date` and `value`.
#' @param language Language for titles and labels: "pt" (Portuguese) or "eng" (English).
#'
#' @return A `ggplot2` object showing the Ibovespa level over time.
#'
#' @examples
#' \donttest{
#' ibov_data <- get_ibovespa("2023-01-01", "2023-12-31")
#' print(plot_ibovespa(ibov_data))
#' }
#'
#' @export
plot_ibovespa <- function(data, language = "eng") {
  .plot_named_series(data, "ibovespa", language)
}
