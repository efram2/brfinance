🎯 Quick Start

In 30 seconds: Get Brazil's key economic indicators

```r
library(brfinance)

# Get current inflation data
inflation <- get_inflation_rate("2023-01-01")
head(inflation)

# Get SELIC rate for policy analysis  
selic <- get_selic_rate(2020, 2024)
plot_selic_rate(selic)

# Check unemployment trends
unemployment <- get_unemployment(2020, 2024)
plot_unemployment(unemployment)
```
