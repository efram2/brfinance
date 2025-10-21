# brfinance 📊🇧🇷

[![CRAN Status](https://www.r-pkg.org/badges/version/brfinance)](https://cran.r-project.org/package=brfinance)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![R-CMD-check](https://github.com/efram2/brfinance/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/efram2/brfinance/actions/workflows/R-CMD-check.yaml)
[![Downloads](https://cranlogs.r-pkg.org/badges/brfinance)](https://cran.r-project.org/package=brfinance)
[![Downloads](https://cranlogs.r-pkg.org/badges/grand-total/brfinance)](https://cran.r-project.org/package=brfinance)
[![GitHub stars](https://img.shields.io/github/stars/efram2/brfinance.svg)](https://github.com/efram2/brfinance/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/efram2/brfinance.svg)](https://github.com/efram2/brfinance/network)

> **Democratizing access to Brazilian economic data** 📈



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
| **Inflation Analysis** | Learn how to download and visualize inflation indicators from official Brazilian sources. | [inflation.Rmd](vignettes/inflation.Rmd) |
| **Selic and Interest Rates** | Explore how to extract and analyze Selic rate data. | [selic.Rmd](vignettes/selic.Rmd) |
| **Unemployment Data** | Understand how to use the package to analyze unemployment rates. | [unemployment.Rmd](vignettes/unemployment.Rmd) |
| **Visualization Guide** | Learn how to create informative visualizations with `brfinance`. | [visualization.Rmd](vignettes/visualization.Rmd) |
| **Introduction to brfinance** | Get started with the basics of the package and its core functions. | [intro_brfinance.Rmd](vignettes/intro_brfinance.Rmd) |


**[1 - Introduction to brfinance](vignettes/intro_brfinance.Rmd)**  
**[2 - Inflation Analysis](vignettes/inflation.Rmd)**  
**[3 - Selic and Interest Rates](vignettes/selic.Rmd)**  
**[4 - Unemployment Data](vignettes/unemployment.Rmd)**  
**[5 - Visualization Guide](vignettes/visualization.Rmd)**

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

