# brfinance 0.9.1

* Data downloads now fail gracefully: if the BCB API (or Yahoo Finance) is
  unavailable, blocks the request or returns an unexpected answer, an
  informative message names the cause and a zero-row data frame is returned
  instead of an error.
* `plot_*()` functions return `NULL` with a message when `data` has no rows.
* Fixed requests for a single day and the handling of HTTP 404 in the
  internal downloader.
* `yfR` moved to Suggests; `jsonlite` added to Imports.
* Vignettes do not use the internet on CRAN.
