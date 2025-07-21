# brfinance

`brfinance` is a simple R package to visualize the Brazilian SELIC interest rate using official data from the Central Bank of Brazil.

## Installation

You can install the development version from GitHub with:

```
install.packages("devtools")  # if not installed
devtools::install_github("seuusuario/brfinance")
```

Usage

The main function is plot_selic(), which plots the Selic rate between two dates.

```
library(brfinance)

# Plot SELIC from January 1, 2022 to January 1, 2024
plot_selic("2022-01-01", "2024-01-01")
```

Functionality

```
plot_selic(inicio, fim): Downloads the official SELIC data series (Meta Selic) from the Brazilian Central Bank API and creates a line chart showing the interest rate evolution between the specified dates.
```
