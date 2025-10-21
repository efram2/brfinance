# brfinance 📊🇧🇷

[![CRAN Status](https://www.r-pkg.org/badges/version/brfinance)](https://cran.r-project.org/package=brfinance)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![R-CMD-check](https://github.com/efram2/brfinance/workflows/R-CMD-check/badge.svg)](https://github.com/efram2/brfinance/actions?style=flat)
[![Downloads](https://cranlogs.r-pkg.org/badges/brfinance)](https://cran.r-project.org/package=brfinance)
[![Downloads](https://cranlogs.r-pkg.org/badges/grand-total/brfinance)](https://cran.r-project.org/package=brfinance)
[![GitHub stars](https://img.shields.io/github/stars/efram2/brfinance.svg)](https://github.com/efram2/brfinance/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/efram2/brfinance.svg)](https://github.com/efram2/brfinance/network)

> **Democratizing access to Brazilian economic data** 📈

`brfinance` is an R package that provides easy access to macroeconomic data from Brazil using official sources like the Central Bank of Brazil (BCB) and IBGE.

## Installation

```r
install.packages("brfinance")

# Or development version from GitHub
install.packages("devtools")
devtools::install_github("efram2/brfinance")

library(brfinance)

```

##  Main features

| Topic | Description |
|-------|--------------|
| [get_selic_rate](https://efram2.github.io/brfinance/articles/intro_brfinance.html) | x |
| [get_inflation_rate](https://efram2.github.io/brfinance/articles/selic.html) | x |
| [get_unemployment](https://efram2.github.io/brfinance/articles/inflation.html) | x |
| [plot_selic_rate](https://efram2.github.io/brfinance/articles/unemployment.html) | x |
| [plot_inflation_rate](https://efram2.github.io/brfinance/articles/visualization.html) | x |

## Quick Start

```R
library(brfinance)

# Get current inflation data
inflation <- get_inflation_rate("2023-01-01")
head(inflation)

# Get SELIC interest rate
selic <- get_selic_rate(2020, 2024)
head(selic)

# Get unemployment rate
unemployment <- get_unemployment(2020, 2024)
head(unemployment)
```
## Language Support

All functions support both English and Portuguese through the language parameter:

* language = "eng" (default): Returns English column names and labels
* language = "pt": Returns Portuguese column names and labels

## About the data

All data used in brfinance is retrieved from official Brazilian institutions:

* SGS (Sistema Gerenciador de Séries Temporais) by the Central Bank of Brazil
* SIDRA (Sistema IBGE de Recuperação Automática) by IBGE

The package aims to simplify the access and visualization of key Brazilian macroeconomic indicators, especially for researchers, students, and analysts who work with national economic data.

## Contribution

Suggestions, feature requests, and pull requests are welcome!

