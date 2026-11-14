# Offline tests: simulate bad answers from the BCB API (no internet needed).
# They check that a misbehaving web resource gives an informative message and
# an empty data frame, never an error.

mock_resp <- function(body, status = 200L, type = "application/json") {
  function(req) {
    httr2::response(
      status_code = status,
      headers = list(`Content-Type` = type),
      body = charToRaw(body)
    )
  }
}

# Runs .get_sgs_series() against a fake answer and returns result + messages
run_sgs <- function(mock, ...) {
  withr::local_options(brfinance.max_tries = 1L)
  msgs <- character()
  res <- withCallingHandlers(
    httr2::with_mocked_responses(
      mock,
      brfinance:::.get_sgs_series(11, "2020-01-01", "2020-12-31")
    ),
    message = function(m) {
      msgs <<- c(msgs, conditionMessage(m))
      invokeRestart("muffleMessage")
    }
  )
  list(res = res, msgs = paste(msgs, collapse = " "))
}

expect_empty_sgs <- function(out, pattern) {
  expect_s3_class(out$res, "data.frame")
  expect_equal(nrow(out$res), 0)
  expect_named(out$res, c("date", "value"))
  expect_match(out$msgs, pattern)
}

test_that("HTML page with HTTP 200 fails gracefully, naming the content type", {
  skip_if_not_installed("httr2", "1.0.0")
  out <- run_sgs(mock_resp("<html>blocked</html>", type = "text/html"))
  expect_empty_sgs(out, "content type 'text/html'")
})

test_that("JSON object (error payload) with HTTP 200 fails gracefully", {
  # This is the case that crashed the vignette on CRAN:
  # `date` must be size 1, not 0
  skip_if_not_installed("httr2", "1.0.0")
  out <- run_sgs(mock_resp('{"error":"rate limit exceeded"}'))
  expect_empty_sgs(out, "unexpected structure")
})

test_that("table without the expected columns fails gracefully", {
  skip_if_not_installed("httr2", "1.0.0")
  out <- run_sgs(mock_resp('[{"foo":"1","bar":"2"}]'))
  expect_empty_sgs(out, "unexpected columns")
})

test_that("unreadable dates fail gracefully", {
  skip_if_not_installed("httr2", "1.0.0")
  out <- run_sgs(mock_resp('[{"data":"2020-01-02","valor":"4.4"}]'))
  expect_empty_sgs(out, "dates")
})

test_that("HTTP 403 fails gracefully, naming the status", {
  skip_if_not_installed("httr2", "1.0.0")
  out <- run_sgs(mock_resp("Forbidden", status = 403L, type = "text/plain"))
  expect_empty_sgs(out, "HTTP 403")
})

test_that("HTTP 404 is treated as 'no data', not as a failure", {
  skip_if_not_installed("httr2", "1.0.0")
  out <- run_sgs(mock_resp("{}", status = 404L))
  expect_empty_sgs(out, "no data available")
})

test_that("empty JSON array is treated as 'no data'", {
  skip_if_not_installed("httr2", "1.0.0")
  out <- run_sgs(mock_resp("[]"))
  expect_empty_sgs(out, "no data available")
})

test_that("a valid answer is parsed", {
  skip_if_not_installed("httr2", "1.0.0")
  body <- '[{"data":"03/01/2020","valor":"4,41"},{"data":"02/01/2020","valor":"4.40"}]'
  out <- run_sgs(mock_resp(body))
  expect_equal(nrow(out$res), 2)
  expect_equal(out$res$value, c(4.40, 4.41))
  expect_equal(out$res$date, as.Date(c("2020-01-02", "2020-01-03")))
  expect_equal(out$msgs, "")
})

test_that("get_* and plot_* functions survive a broken API", {
  skip_if_not_installed("httr2", "1.0.0")
  withr::local_options(brfinance.max_tries = 1L)
  bad <- mock_resp("<html></html>", type = "text/html")

  suppressMessages(httr2::with_mocked_responses(bad, {
    inflation <- get_inflation_rate("2020", "2021")
    selic     <- get_selic_rate("2020", "2021")
    cdi       <- get_cdi_rate("2020", "2021")
    target    <- get_ipca_from_target("2020", "2021")
  }))

  expect_equal(nrow(inflation), 0)
  expect_true(all(c("date", "value", "ytd_inflation", "twelve_month_inflation") %in% names(inflation)))
  expect_equal(nrow(selic), 0)
  expect_equal(nrow(cdi), 0)
  expect_equal(nrow(target), 0)

  expect_message(p1 <- plot_selic_rate(selic), "No data to plot")
  expect_null(p1)
  expect_message(p2 <- plot_inflation_rate(inflation), "No data to plot")
  expect_null(p2)
  expect_message(
    p3 <- plot_series_comparison(
      list(SELIC = selic, CDI = cdi), c("value", "value"), c("date", "date")
    ),
    "No data to plot"
  )
  expect_null(p3)
})

test_that(".split_date_windows handles one day and long ranges", {
  w1 <- brfinance:::.split_date_windows(as.Date("2023-06-15"), as.Date("2023-06-15"))
  expect_equal(nrow(w1), 1)

  w2 <- brfinance:::.split_date_windows(as.Date("2000-01-01"), as.Date("2024-12-31"))
  expect_gt(nrow(w2), 2)
  expect_equal(w2$start[1], as.Date("2000-01-01"))
  expect_equal(w2$end[nrow(w2)], as.Date("2024-12-31"))
  expect_true(all(w2$start[-1] == w2$end[-nrow(w2)] + 1))
})

test_that(".normalize_date accepts valid input and rejects bad input", {
  expect_equal(brfinance:::.normalize_date("2024-02", is_start = FALSE), as.Date("2024-02-29"))
  expect_equal(brfinance:::.normalize_date(2020, is_start = TRUE), as.Date("2020-01-01"))
  expect_equal(brfinance:::.normalize_date(as.Date("2020-05-05")), as.Date("2020-05-05"))
  expect_error(brfinance:::.normalize_date("2020-13"), "Invalid date")
  expect_error(brfinance:::.normalize_date("banana"), "Invalid date")
})
