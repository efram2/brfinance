# brfinance

brfinance is a simple R package that allows you to access and visualize financial data from Brazil, including the basic interest rate (SELIC) and the unemployment rate, using official sources such as the Central Bank of Brazil (BCB) and IBGE (via SIDRA).

## Installation

You can install the development version from GitHub with:

```
install.packages("devtools")  # if not installed
devtools::install_github("efram2/brfinance")
```

## Usage

The main functions are plot_selic() and plot_desemprego), which plots the Selic and Desemprego rate between two dates.

```
library(brfinance)

# Gráfico da taxa Selic de 2020 a 2024
plot_selic(2020, 2024)

# Gráfico da taxa de desemprego de 2018 a 2024
plot_desemprego(2018, 2024)

```

## Functionality

**plot_selic(ano_inicio, ano_fim)**

* Download the official historical series of the SELIC Target (SGS/BCB code 432).
* Displays a line graph between the specified years.
* Source: Central Bank of Brazil (SGS).

**plot_desemprego(ano_inicio, ano_fim)**

* Consult the unemployment rate data in Brazil (SIDRA/IBGE code 6381).
* Shows the evolution of the rate quarterly in the period reported.
* Source: IBGE (SIDRA/Continuous PNAD).
