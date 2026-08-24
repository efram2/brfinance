
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

**brfinance** puts Brazil’s official macroeconomic data — interest
rates, inflation, exchange rates, unemployment, GDP — and a set of
financial-math calculators behind a single, consistent R interface. One
function call gets you a clean `data.frame`; one more gets you a
ready-to-share `ggplot2` chart.

If your work touches **Brazilian interest rates**, **inflation**,
**exchange rates**, or plain **financial math** (present/future value,
NPV, IRR, amortization…), this package saves you from hand-rolling BCB
API calls every time.

> **Looking for stock/equity data instead?** brfinance focuses on macro
> series (rates, inflation, GDP) from the Central Bank and IBGE. For
> individual B3 stocks, portfolios, and Markowitz-style analysis, see
> the companion package
> **[{brstocks}](https://github.com/efram2/brstocks)**.

------------------------------------------------------------------------

## Why brfinance?

With **brfinance**, you can:

- Pull **official Brazilian macro indicators** (BCB & IBGE) with one
  function call
- Get the **Ibovespa index** and compare it against rates/inflation on
  the same chart
- Run standard **financial calculations** (NPV, IRR, PV, FV, PMT,
  amortization schedules, and more)
- Plot any indicator with **one line of code** — consistent styling
  across the whole package
- Get output in **Portuguese or English**, your choice, without changing
  how you call the function

No manual API requests. No scraping. No reshaping raw JSON by hand —
brfinance does that once, so you don’t have to do it every time.

------------------------------------------------------------------------

# Installation

``` r
install.packages("brfinance")

# Or the development version, straight from GitHub
install.packages("devtools")
devtools::install_github("efram2/brfinance")

library(brfinance)
```

# 🚀 Quick Start

Every `get_*()` function returns a plain `data.frame` with `date` and
`value` columns (plus a couple of extras where it makes sense, like
`get_ipca_from_target()` below) — so once you’ve learned one, you’ve
learned the pattern for all of them.

**Inflation (IPCA)**

``` r
plot_inflation_rate(
  get_inflation_rate("2020", "2024")
)
```

<img src="README_files/figure-gfm/fig.ipca-1.png" alt="" style="display: block; margin: auto;" />

**SELIC interest rate**

``` r
plot_selic_rate(
  get_selic_rate("2020", "2024")
)
```

<img src="README_files/figure-gfm/fig.selic-1.png" alt="" style="display: block; margin: auto;" />

**Unemployment rate**

``` r
plot_unemployment(
  get_unemployment("2019", "2024")
)
```

<img src="README_files/figure-gfm/fig.unemp-1.png" alt="" style="display: block; margin: auto;" />

**Ibovespa index**

Want equity-market context alongside your macro series? `get_ibovespa()`
pulls the daily Ibovespa close (via Yahoo Finance) in the same
`date`/`value` shape as everything else, so it drops straight into
`plot_ibovespa()` or into a comparison chart with any other indicator
below.

``` r
plot_ibovespa(
  get_ibovespa("2020-01-01", "2024-12-31")
)
```

<img src="README_files/figure-gfm/fig.ibov-1.png" alt="" style="display: block; margin: auto;" />

*(Remember: this is the benchmark index only. For individual stocks,
portfolio construction, or an efficient-frontier simulator, that’s what
[{brstocks}](https://github.com/efram2/brstocks) is for.)*

**IPCA vs. the inflation target**

A common question in Brazilian macro analysis: is inflation running
above or below the Central Bank’s target? `get_ipca_from_target()`
answers it directly — it returns the 12-month accumulated IPCA, the
CMN’s official target for that year, and the gap between them, all in
one `data.frame`.

``` r
ipca_gap <- get_ipca_from_target("2015", "2024")
head(ipca_gap)
```

    ##         date ipca_12m target  gap
    ## 1 2015-01-01     7.14    4.5 2.64
    ## 2 2015-02-01     7.70    4.5 3.20
    ## 3 2015-03-01     8.13    4.5 3.63
    ## 4 2015-04-01     8.17    4.5 3.67
    ## 5 2015-05-01     8.47    4.5 3.97
    ## 6 2015-06-01     8.89    4.5 4.39

**Compare multiple indicators in one chart**

You can compare different economic indicators three ways:

1.  Raw values, on their original scale
2.  Indexed series (base = first observation = 100)
3.  Percentage change from the first observation

``` r
plot_series_comparison(
  data_list = list(
    "SELIC" = get_selic_rate("2020", "2024"),
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

<img src="README_files/figure-gfm/fig.compare-1.png" alt="" style="display: block; margin: auto;" />

**…or on two separate axes, keeping each series’ native scale**

When the series you’re comparing have very different units — a rate in %
vs. an exchange rate in R\$ — indexing them can hide what actually
matters. Set `dual_axis = TRUE` (only for exactly two series) to plot
each on its own y-axis instead:

``` r
plot_series_comparison(
  data_list = list(
    "SELIC" = get_selic_rate("2020", "2024"),
    "Exchange Rate" = get_exchange_rate("2020-01-01", "2024-12-31")
  ),
  y_vars = c("value", "value"),
  date_vars = c("date", "date"),
  dual_axis = TRUE,
  title = "SELIC vs. USD/BRL Exchange Rate"
)
```

<img src="README_files/figure-gfm/fig.dual-1.png" alt="" style="display: block; margin: auto;" />

**Financial calculators**

``` r
# Net Present Value
calc_npv(rate = 0.1, cashflows = c(-1000, 300, 400, 500))
```

    ## [1] -21.03681

``` r
# Internal Rate of Return
calc_irr(cashflows = c(-1000, 300, 400, 500))
```

    ## [1] 0.08896339

``` r
# Loan payment
calc_pmt(pv = 10000, rate = 0.02, n = 24)
```

    ## [1] 528.711

``` r
# Full amortization schedule for a loan
head(calc_amortization_schedule(pv = 10000, rate = 0.01, n = 12))
```

    ##   Period Beginning_Balance  Payment  Interest Principal Ending_Balance
    ## 1      1         10000.000 888.4879 100.00000  788.4879       9211.512
    ## 2      2          9211.512 888.4879  92.11512  796.3728       8415.139
    ## 3      3          8415.139 888.4879  84.15139  804.3365       7610.803
    ## 4      4          7610.803 888.4879  76.10803  812.3799       6798.423
    ## 5      5          6798.423 888.4879  67.98423  820.5037       5977.919
    ## 6      6          5977.919 888.4879  59.77919  828.7087       5149.211

# Function Reference

## Data retrieval functions (`get_*`)

- `get_inflation_rate()` — Brazil’s official inflation rate (IPCA),
  monthly
- `get_ipca_from_target()` — 12-month accumulated IPCA vs. the CMN’s
  official inflation target, plus the gap between them
- `get_selic_rate()` — Daily SELIC interest rate, annualized (base 252)
- `get_cdi_rate()` — Daily CDI interbank rate, annualized
- `get_exchange_rate()` — USD/BRL exchange rate
- `get_gdp_growth()` — GDP growth rates
- `get_unemployment()` — Unemployment rate (PNAD Contínua)
- `get_ibovespa()` — Ibovespa index closing level (via Yahoo Finance)
- `browse_series()` / `get_series_info()` — Explore the full catalog of
  Central Bank (SGS) series available, beyond the ones wrapped above

All `get_*` functions accept flexible date inputs: `"YYYY"`,
`"YYYY-MM"`, or `"YYYY-MM-DD"`. Requests spanning more than 10 years are
chunked and stitched together automatically, since that’s the Central
Bank API’s own limit per request — not something you need to work around
yourself.

------------------------------------------------------------------------

## Plotting functions (`plot_*`)

- `plot_inflation_rate()` — Plots IPCA inflation over time
- `plot_selic_rate()` — Plots the SELIC interest rate
- `plot_cdi_rate()` — Plots the CDI interest rate
- `plot_exchange_rate()` — Plots exchange rate time series
- `plot_unemployment()` — Plots unemployment rate time series
- `plot_ibovespa()` — Plots the Ibovespa index
- `plot_series_comparison()` — Compares multiple economic indicators in
  one chart, indexed/raw/percent-change, or on a dual axis
  (`dual_axis = TRUE`)

Every `plot_*()` function shares the same visual language: a
financial-market blue for benchmark rates (SELIC, CDI, exchange rate,
Ibovespa) and a market red for cost/risk indicators (inflation,
unemployment), so charts from different functions read consistently side
by side.

------------------------------------------------------------------------

## Financial calculators (`calc_*`)

- `calc_present_value()` — Present Value
- `calc_future_value()` / `calc_compound_interest()` — Future Value /
  Compound Interest (same formula, two names for two common ways people
  search for it)
- `calc_future_value_ext()` — Future Value with periodic payments
- `calc_simple_interest()` — Simple interest
- `calc_effective_rate()` / `calc_nominal_rate()` — Convert between
  nominal and effective rates
- `calc_pv_annuity()` / `calc_fv_annuity()` — Present/future value of an
  annuity
- `calc_pmt()` — Loan payment amount
- `calc_rate()` — Solve for the interest rate per period
- `calc_nper()` — Solve for the number of periods
- `calc_npv()` — Net Present Value
- `calc_irr()` — Internal Rate of Return
- `calc_amortization_schedule()` — Full loan amortization schedule
- `calc_continuous_compounding()` / `calc_pv_continuous()` — Continuous
  compounding, future and present value
- `rule_of_72()` / `rule_of_114()` — Quick estimate of years to double /
  triple an investment

# Language Support

Every `get_*()` function accepts a `language` argument:

- `language = "eng"` (default) — English variable labels
- `language = "pt"` — Portuguese variable labels

Column names themselves (`date`, `value`, …) stay the same either way,
so switching `language` never breaks a pipeline built on top of a
`get_*()` call — it only changes the descriptive labels attached to the
data (visible via `labelled::var_label()`).

# Data sources

All data comes from **official Brazilian institutions**:

- Central Bank of Brazil (BCB / SGS)
- IBGE (PNAD Contínua unemployment data, replicated by the Central Bank
  via SGS – not fetched directly from IBGE’s SIDRA API)
- Yahoo Finance, for the Ibovespa index (`get_ibovespa()`)

# Related package

For individual B3 stocks, portfolio simulation, and an interactive
Markowitz efficient-frontier dashboard, check out
**[{brstocks}](https://github.com/efram2/brstocks)** — brfinance’s
sister package, focused on the equity side of Brazilian markets.

# Contribution

Suggestions, feature requests, and pull requests are welcome!
