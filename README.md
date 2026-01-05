README
================
brfinance
2026-01-05

# brfinance 📊🇧🇷

[![CRAN
Status](https://www.r-pkg.org/badges/version/brfinance)](https://cran.r-project.org/package=brfinance)
[![License:
MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![R-CMD-check](https://github.com/efram2/brfinance/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/efram2/brfinance/actions/workflows/R-CMD-check.yaml)
[![Downloads](https://cranlogs.r-pkg.org/badges/grand-total/brfinance)](https://cran.r-project.org/package=brfinance)
[![Downloads](https://cranlogs.r-pkg.org/badges/brfinance)](https://cran.r-project.org/package=brfinance)
[![GitHub
stars](https://img.shields.io/github/stars/efram2/brfinance.svg)](https://github.com/efram2/brfinance/stargazers)
[![GitHub
forks](https://img.shields.io/github/forks/efram2/brfinance.svg)](https://github.com/efram2/brfinance/network)

**brfinance** is an R package that brings together **official Brazilian
macroeconomic data** and **practical financial calculators** in a
simple, ready-to-use interface.

If you work with **Brazilian data**, **interest rates**, **inflation**,
or **financial math**, this package is for you.

------------------------------------------------------------------------

## Why brfinance?

With **brfinance**, you can:

- Access **official Brazilian macroeconomic indicators** (BCB & IBGE)
- Run **financial calculations** (NPV, IRR, PV, FV, PMT, rates)
- Plot key indicators with **one line of code**
- Use **Portuguese or English** outputs seamlessly

No APIs. No scraping. No manual cleaning.

------------------------------------------------------------------------

# Installation

``` r
install.packages("brfinance")

# Or development version from GitHub
install.packages("devtools")
devtools::install_github("efram2/brfinance")

library(brfinance)
```

# 🚀 Quick Start

Inflation (IPCA)

``` r
plot_inflation_rate(
  get_inflation_rate("2020", "2024")
)
```

<img src="README_files/figure-gfm/fig.ipca-1.png" style="display: block; margin: auto;" />

SELIC interest rate

``` r
plot_selic_rate(
  get_selic_rate(2020, 2024)
)
```

<img src="README_files/figure-gfm/fig.selic-1.png" style="display: block; margin: auto;" />

Unemployment rate

``` r
plot_unemployment(
  get_unemployment("2019", "2024")
)
```

<img src="README_files/figure-gfm/fig.unemp-1.png" style="display: block; margin: auto;" />

Compare multiple indicators in one chart

- Want to analyze how different economic indicators evolve together?
- Use *plot_series_comparison()* to compare multiple time series in a
  single, clean visualization.

``` r
plot_series_comparison(
  data_list = list(
    "SELIC" = get_selic_rate(2020, 2024),
    "IPCA"  = get_inflation_rate("2020", "2024"),
    "Unemployment" = get_unemployment("2020", "2024")
  ),
  y_vars = rep("value", 3),
  date_vars = rep("date", 3),
  scale_type = "index",
  title = "Brazilian Economic Indicators",
  subtitle = "Indexed comparison (base = first observation)"
)
```

<img src="README_files/figure-gfm/fig.compare-1.png" style="display: block; margin: auto;" />

## Financial Calculators (minimalista)

``` r
# Net Present Value
calc_npv(0.1, c(-1000, 300, 400, 500))

# Internal Rate of Return
calc_irr(c(-1000, 300, 400, 500))

# Loan payment
calc_pmt(rate = 0.02, n = 24, pv = 10000)
```

# Available Features

- Inflation (IPCA)
- SELIC and CDI rates
- Exchange rates
- GDP growth
- Unemployment (PNAD Contínua)
- Central Bank time series (SGS)

# Financial Calculators

- Present & Future Value (PV / FV)
- Compound & continuous interest
- NPV, IRR, PMT, rate, nper
- Annuities and amortization schedules
- Rule of 72 and Rule of 114

# Visualization

- Inflation, SELIC, CDI and exchange rate plots
- Unemployment time series
- Multi-series comparison plots

# Language Support

All main functions support bilingual output:

- language = “eng” (default): Returns English column names and labels
- language = “pt”: Returns Portuguese column names and labels

# Data sources

All data come from *official Brazilian institutions:*

- Central Bank of Brazil (BCB / SGS)
- IBGE (SIDRA / PNAD Contínua)

# Contribution

Suggestions, feature requests, and pull requests are welcome!
