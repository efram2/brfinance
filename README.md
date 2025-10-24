# brfinance 📊🇧🇷

[![CRAN Status](https://www.r-pkg.org/badges/version/brfinance)](https://cran.r-project.org/package=brfinance)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![R-CMD-check](https://github.com/efram2/brfinance/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/efram2/brfinance/actions/workflows/R-CMD-check.yaml)
[![pkgdown](https://github.com/efram2/brfinance/actions/workflows/pkgdown.yaml/badge.svg)](https://efram2.github.io/brfinance/)
[![Downloads](https://cranlogs.r-pkg.org/badges/grand-total/brfinance)](https://cran.r-project.org/package=brfinance)
[![Downloads](https://cranlogs.r-pkg.org/badges/brfinance)](https://cran.r-project.org/package=brfinance)
[![GitHub stars](https://img.shields.io/github/stars/efram2/brfinance.svg)](https://github.com/efram2/brfinance/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/efram2/brfinance.svg)](https://github.com/efram2/brfinance/network)


## Overview

The `brfinance` package simplifies access to official Brazilian macroeconomic data from reliable institutions such as the Central Bank of Brazil (BCB) and the IBGE.
It is designed to make it easier to collect, organize, and visualize key indicators like inflation, interest rates, and unemployment, directly from R.

## Installation

```r
install.packages("brfinance")

# Or development version from GitHub
install.packages("devtools")
devtools::install_github("efram2/brfinance")

library(brfinance)

```

##  Documentation and Vignettes

Explore the main vignettes included in **brfinance** to learn how to use each feature:

| Vignette | Description | Rmd |
|-----------|--------------|------|
| **Introduction to brfinance** | Get started with the basics of the package and its core functions. | [click here to learn more](https://efram2.github.io/brfinance/intro_brfinance.html) |
| **Inflation Analysis** | Learn how to download and visualize inflation indicators from official Brazilian sources. | [click here to learn more](https://efram2.github.io/brfinance/inflation.html) |
| **Selic and Interest Rates** | Explore how to extract and analyze Selic rate data. | [click here to learn more](https://efram2.github.io/brfinance/selic.html) |
| **Unemployment Data** | Understand how to use the package to analyze unemployment rates. | [click here to learn more](https://efram2.github.io/brfinance/unemployment.html) |

## Quick Start

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

