## Motivation

This release fixes several correctness bugs affecting the values returned
by core data-retrieval functions (an incorrectly documented SELIC series,
a date-handling bug that crashed `get_inflation_rate()` under normal use,
and a query-window issue that caused `get_unemployment()` to fail with a
404 from the underlying API), adds automatic pagination for requests
spanning more than the upstream API's 10-year window limit, and adds two
new functions (`get_ibovespa()` and `get_ipca_from_target()`). No exported
function signatures were removed or changed in a backward-incompatible
way.

## Test environments
* Local OS: Windows 11, R 4.4.1
* R-hub: Windows (release), Fedora Linux, Ubuntu, macOS (Intel)
* GitHub Actions: ubuntu-latest (R-devel, R-release)
* Win-builder: R-devel (win-builder.r-project.org)

## R CMD check results
0 errors | 0 warnings | 0 notes

## New dependency in this release
* This release adds `yfR` to `Imports`, used by the new `get_ibovespa()`
  function to retrieve the daily closing level of the Ibovespa index from
  Yahoo Finance. No authentication or API key is required; only public,
  freely available index-level data is retrieved. This follows the same
  optional-dependency pattern (guarded with `requireNamespace()`) already
  used elsewhere in the package for `labelled`.

## Key changes in this release

Bug fixes:
* `get_selic_rate()` now returns both the daily and annualized SELIC rate
  in separate columns, computed consistently with `get_cdi_rate()`
  (previously only a single, ambiguously documented column was returned).
* Fixed a bug in `get_inflation_rate()` that raised an error under normal,
  documented usage (`filter()` comparison against an unset `end_date`).
* Fixed `get_unemployment()` returning no data / a 404 from the underlying
  API for its documented default date range.
* `.get_sgs_series()` (internal) now automatically splits requests
  spanning more than 10 years into sequential sub-requests and combines
  the results, since the upstream Central Bank of Brazil API rejects
  date ranges longer than that in a single call.
* Corrected a date-normalization bug where the last day of a given month
  was computed incorrectly (hardcoded instead of calendar-derived),
  affecting leap Februaries and 30/31-day months.
* Removed a duplicated function body (`calc_compound_interest()` is now
  an alias of `calc_future_value()`, which computes the same formula).
* Fixed a non-ASCII character in a string literal that triggered an
  R CMD check WARNING, and declared a previously-undeclared package
  dependency used via `requireNamespace()`.
* Updated function examples to use `\donttest{}` for calls that depend on
  a live web API, to ensure compliance with CRAN policies.

New features (non-breaking):
* Added `get_ibovespa()` / `plot_ibovespa()` to retrieve and plot the
  daily Ibovespa index level.
* Added `get_ipca_from_target()`, which returns 12-month accumulated IPCA
  inflation alongside the official inflation target and the gap between
  them.
* Added a `dual_axis` option to `plot_series_comparison()` for comparing
  two series on their native scales rather than a common index.

Documentation / maintenance:
* Fixed broken URLs/badges in README.md.
* Corrected inaccurate terminology in `get_gdp_growth()`'s documentation
  (the underlying series has monthly, not quarterly, frequency).
* General code cleanup and consolidation of near-duplicate plotting
  functions into a shared internal implementation.

## Downstream dependencies
There are currently no downstream dependencies for this package.

## About terms and acronyms in the package
* The package provides easy access to Brazilian macroeconomic and
  financial data. To clarify some domain-specific terms that appear
  throughout the documentation and are intentionally not translated:
  - **SELIC** (or **Selic**) refers to the *Sistema Especial de
    Liquidação e Custódia*, the Brazilian Central Bank's benchmark
    interest rate, equivalent to a policy/base rate.
  - **Desemprego** means *unemployment*, a standard labor-market
    indicator.
  - **Ibovespa** (*Índice Bovespa*) is the main stock market index of
    B3, Brazil's stock exchange -- broadly analogous to the S&P 500 or
    the FTSE 100 as a country-level equity benchmark. It is retrieved in
    this release via Yahoo Finance (ticker `^BVSP`), the same public,
    no-authentication data source already used by the companion package
    `{brstocks}`.
* These are established proper names / institutional terms in Brazilian
  economic and financial analysis, kept in their original form for
  accuracy and to match how users of this domain expect to find them.
* All date/time outputs follow the system's locale. Should any NOTE
  related to localized day/month names appear on a given check platform,
  it reflects the checking environment's locale settings rather than a
  package issue.
