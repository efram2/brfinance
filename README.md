# brfinance

brfinance is a simple R package that provides easy access to macroeconomic data from Brazil, such as the basic interest rate (SELIC) and the unemployment rate, using official sources like the Central Bank of Brazil (BCB) and the Brazilian Institute of Geography and Statistics (IBGE) via SIDRA.

This package is part of an effort to simplify the retrieval and visualization of Brazilian macroeconomic indicators directly in R, and soon visualizations of financial market trends.
## Installation

You can install the development version from GitHub with:

```
install.packages("devtools")  # if not installed
devtools::install_github("efram2/brfinance")
```

## Usage

The two main functions currently available are:

```
library(brfinance)

# Plot the SELIC interest rate from 2020 to 2024
plot_selic(2020, 2024)

# Plot the unemployment rate from 2018 to 2024
plot_desemprego(2018, 2024)

```

## Functionality

**plot_selic(start_year, end_year)**

* Downloads the official historical daily series of the SELIC Target Rate, using the Central Bank of Brazil's SGS system (series code 432).
* Displays a line chart showing the evolution of the rate between the selected years.
* ⚠️ Limitation: The function only works when the interval between start_year and end_year is less than 10 years, due to API constraints from the Central Bank of Brazil.
* Source: Central Bank of Brazil (SGS).

**plot_desemprego(start_year, end_year)**

* Retrieves the quarterly unemployment rate in Brazil using SIDRA (IBGE database), series code 6381 from the Continuous PNAD survey.
* Displays a time series graph showing how the rate changed across the specified years.
* Source: IBGE (SIDRA/PNAD Contínua).

## About the data

All data used in brfinance is retrieved from official Brazilian institutions:

* SGS (Sistema Gerenciador de Séries Temporais) by the Central Bank of Brazil
* SIDRA (Sistema IBGE de Recuperação Automática) by IBGE

The package aims to simplify the access and visualization of key Brazilian macroeconomic indicators, especially for researchers, students, and analysts who work with national economic data.

## Contribution

Suggestions, feature requests, and pull requests are welcome!

