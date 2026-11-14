## Resubmission

This is a resubmission of brfinance, which was archived because of the
check problems reported by the CRAN team (the package did not fail
gracefully when the Central Bank of Brazil API returned an unexpected
answer, which made the `selic` vignette fail).

## What was wrong and what changed

* The internal downloader assumed that any JSON answer was a table of
  observations. When the web service answered with something else (an HTML
  page, or a JSON error object instead of a table), the code reached
  `dplyr::mutate()` without the expected columns and failed with
  "`date` must be size 1, not 0".
* `.get_sgs_series()` now checks, in this order: connection errors, HTTP
  status, content type, JSON validity, table structure (columns `data` and
  `valor`) and date format. On any problem it prints a message that names
  the cause (e.g. "returned content type 'text/html'", "HTTP 403",
  "unexpected columns") and returns a zero-row data frame, as the CRAN policy
  asks. It never throws an error or warning because of the web resource.
* A `return()` inside `tryCatch()` that leaked an internal value on HTTP 404,
  and a crash for single-day requests, were fixed.
* `get_*()` functions return zero-row data frames and `plot_*()` functions
  return `NULL` with a message when there is no data, so examples run with
  `\donttest{}` cannot fail when the API is down.
* Vignettes only evaluate chunks that use the internet when `NOT_CRAN=true`
  and the API answers. New offline tests (mocked HTTP answers) cover HTML,
  JSON error objects, wrong columns, HTTP 403/404 and empty answers.
* `yfR` moved from Imports to Suggests (it is only used by `get_ibovespa()`
  and is already guarded with `requireNamespace()`); `jsonlite` is now
  declared in Imports because it is used directly; the unnecessary `tidyr`
  requirement in `plot_series_comparison()` was removed.

## Test environments
* TODO: fill in after running the checks (local OS / R version, win-builder,
  R-hub, GitHub Actions).
* Also checked with the internet disabled.

## R CMD check results
TODO: paste the result of `devtools::check(args = "--as-cran")`.

## Downstream dependencies
There are currently no downstream dependencies for this package.

## Notes in the incoming check

* "New submission" / "Package was archived on CRAN": this is a resubmission.
  The previous version was archived because the vignettes and examples failed
  when the BCB API was unavailable. All web access now fails gracefully
  (informative message, empty result, no error or warning), and the vignettes
  do not need internet on CRAN.
* Possibly misspelled words: 'SGS' (Sistema Gerenciador de Séries Temporais,
  the Central Bank of Brazil's time series system) and 'Selic' (Brazil's
  benchmark interest rate) are proper names, now quoted in DESCRIPTION.
* URL: the yfR link in README.md was updated to its new address
  (https://github.com/ropensci/yfR).
