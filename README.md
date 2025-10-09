# brfinance

brfinance is a simple R package that provides easy access to macroeconomic data from Brazil, such as the basic interest rate (SELIC) and the unemployment rate, using official sources like the Central Bank of Brazil (BCB) and the Brazilian Institute of Geography and Statistics (IBGE) via SIDRA.

This package is part of an effort to simplify the retrieval and visualization of Brazilian macroeconomic indicators directly in R, and soon visualizations of financial market trends.

## Installation

You can install the development version from GitHub with:

```r
install.packages("devtools")  # if not installed
devtools::install_github("efram2/brfinance")
```

## Usage

The package provides separate functions for data retrieval and visualization:


```
library(brfinance)

# Example 1: SELIC rate (English)
selic_data <- get_selic_rate(2020, 2024)
selic_plot <- plot_selic_rate(selic_data)
print(selic_plot)

# Example 2: Unemployment rate (English)
unemployment_data <- get_unemployment(2020, 2024)
unemployment_plot <- plot_unemployment(unemployment_data)
print(unemployment_plot)

# Example 3: Portuguese versions
dados_selic <- get_selic_rate(2020, 2024, language = "pt")
grafico_selic <- plot_selic_rate(dados_selic, language = "pt")
print(grafico_selic)

```

## Available Functions

**get_selic_rate(start_year, end_year, language = "eng")**

* Downloads the official historical daily series of the SELIC Target Rate, using the Central Bank of Brazil's SGS system (series code 432).
* Returns a dataframe with the SELIC rate data.
* Supports both English ("eng") and Portuguese ("pt") column names.
* Source: Central Bank of Brazil (SGS).

**get_unemployment(start_year, end_year, language = "eng")**

* Retrieves the quarterly unemployment rate in Brazil using SIDRA (IBGE database), series code 6381 from the Continuous PNAD survey.
* Returns a dataframe with the unemployment rate data.
* Supports both English ("eng") and Portuguese ("pt") column names.
* Source: IBGE (SIDRA/PNAD Contínua).

## Visualization Functions

**plot_selic_rate(data, language = "eng")**

* Creates a time series plot of the SELIC interest rate.
* Accepts data from get_selic_rate() function.
* Supports both English and Portuguese labels.

**plot_unemployment(data, language = "eng")**

* Creates a time series plot of the unemployment rate.
* Accepts data from get_unemployment() function.
* Supports both English and Portuguese labels.

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

