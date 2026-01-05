# brfinance 📊🇧🇷

[![CRAN Status](https://www.r-pkg.org/badges/version/brfinance)](https://cran.r-project.org/package=brfinance)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![R-CMD-check](https://github.com/efram2/brfinance/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/efram2/brfinance/actions/workflows/R-CMD-check.yaml)
[![Downloads](https://cranlogs.r-pkg.org/badges/grand-total/brfinance)](https://cran.r-project.org/package=brfinance)
[![Downloads](https://cranlogs.r-pkg.org/badges/brfinance)](https://cran.r-project.org/package=brfinance)
[![GitHub stars](https://img.shields.io/github/stars/efram2/brfinance.svg)](https://github.com/efram2/brfinance/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/efram2/brfinance.svg)](https://github.com/efram2/brfinance/network)

**brfinance** is an R package that brings together **official Brazilian macroeconomic data** and **practical financial calculators** in a simple, ready-to-use interface.

If you work with **Brazilian data**, **interest rates**, **inflation**, or **financial math**, this package is for you.

---

## Why brfinance?

With **brfinance**, you can:

- Access **official Brazilian macroeconomic indicators** (BCB & IBGE)
- Run **financial calculations** (NPV, IRR, PV, FV, PMT, rates)
- Plot key indicators with **one line of code**
- Use **Portuguese or English** outputs seamlessly

No APIs. No scraping. No manual cleaning.

---

# Installation

```r
install.packages("brfinance")

# Or development version from GitHub
install.packages("devtools")
devtools::install_github("efram2/brfinance")

library(brfinance)

```
# 🚀 Quick Start

Inflation (IPCA)
```r
inflation <- get_inflation_rate("2020-01-01", "2024-01-01")
head(inflation)
```

SELIC interest rate
```r
selic <- get_selic_rate(2020, 2024)
plot_selic_rate(selic)
``` 

Unemployment rate
```r
unemp <- get_unemployment("2019", "2024")
plot_unemployment(unemp)
``` 

✅ Flexible date input
All get_* functions accept dates in the following formats:

* "YYYY"
* "YYYY-MM"
* "YYYY-MM-DD"

Strings ("") are always required except when passing only the year, where 2025 is also valid.
Financial calculations

🔍 Compare multiple indicators in one chart
Want to analyze how different economic indicators evolve together?
Use *plot_series_comparison()* to compare multiple time series in a single, clean visualization.
```r
selic <- get_selic_rate(2020, 2024)
ipca  <- get_inflation_rate("2020-01", "2024-01")
unemp <- get_unemployment("2020-01-01", "2024-01-01")

comparison_plot <- plot_series_comparison(
  data_list = list(
    "SELIC" = selic,
    "IPCA" = ipca,
    "Unemployment" = unemp
  ),
  y_vars = c("value", "value", "value"),
  date_vars = c("date", "date", "date"),
  scale_type = "index",
  title = "Brazilian Economic Indicators",
  subtitle = "Indexed comparison (base = first observation)",
  y_label = "Index",
  language = "eng"
)

print(comparison_plot)
```

![Comparison of Brazilian Economic Indicators](man/figures/series_comparison.png)


```r
# Net Present Value
calc_npv(rate = 0.1, cashflows = c(-1000, 300, 400, 500))

# Internal Rate of Return
calc_irr(c(-1000, 300, 400, 500))

# Loan payment
calc_pmt(rate = 0.02, n = 24, pv = 10000)
```



# Quick Start

```R
library(brfinance)

# Download inflation data for 2023
inflation <- get_inflation_rate("2023-01-01")
head(inflation)

# Retrieve SELIC rate from 2020 to 2024
selic <- get_selic_rate(2020, 2024)
head(selic)

# Retrieve unemployment data
unemployment <- get_unemployment(2020, 2024)
head(unemployment)
```
# Available Features

* Inflation (IPCA)
* SELIC and CDI rates
* Exchange rates
* GDP growth
* Unemployment (PNAD Contínua)
* Central Bank time series (SGS)

# Financial Calculators

* Present & Future Value (PV / FV)
* Compound & continuous interest
* NPV, IRR, PMT, rate, nper
* Annuities and amortization schedules
* Rule of 72 and Rule of 114

# Visualization

* Inflation, SELIC, CDI and exchange rate plots
* Unemployment time series
* Multi-series comparison plots

# Language Support

All main functions support bilingual output:

* language = "eng" (default): Returns English column names and labels
* language = "pt": Returns Portuguese column names and labels

# Data sources

All data come from *official Brazilian institutions:*

* Central Bank of Brazil (BCB / SGS)
* IBGE (SIDRA / PNAD Contínua)

# Contribution

Suggestions, feature requests, and pull requests are welcome!

