# -------------------------------------------------------------------
# Financial calculators
# -------------------------------------------------------------------

#' Present Value (PV)
#'
#' Calculates the present value of a future amount given an interest rate
#' and number of periods.
#'
#' @param fv Future value.
#' @param rate Interest rate per period (decimal, e.g. 0.05 for 5%).
#' @param n Number of periods.
#'
#' @return Present value.
#'
#' @examples
#' calc_present_value(fv = 1100, rate = 0.10, n = 1)
#' calc_present_value(fv = 1000, rate = 0.05, n = 5)
#'
#' @export
calc_present_value <- function(fv, rate, n) {
  stopifnot(
    is.numeric(fv), length(fv) == 1,
    is.numeric(rate), length(rate) == 1,
    is.numeric(n), length(n) == 1,
    n >= 0
  )

  fv / (1 + rate)^n
}


#' Future Value (FV)
#'
#' Calculates the future value of a present amount given an interest rate
#' and number of periods.
#'
#' @param pv Present value.
#' @param rate Interest rate per period (decimal).
#' @param n Number of periods.
#'
#' @return Future value.
#'
#' @examples
#' calc_future_value(pv = 1000, rate = 0.10, n = 1)
#' calc_future_value(pv = 500, rate = 0.05, n = 10)
#'
#' @export
calc_future_value <- function(pv, rate, n) {
  stopifnot(
    is.numeric(pv), length(pv) == 1,
    is.numeric(rate), length(rate) == 1,
    is.numeric(n), length(n) == 1,
    n >= 0
  )

  pv * (1 + rate)^n
}


#' Simple Interest
#'
#' Calculates the final value under simple interest.
#'
#' @param pv Present value.
#' @param rate Interest rate per period (decimal).
#' @param n Number of periods.
#'
#' @return Final value with simple interest.
#'
#' @examples
#' calc_simple_interest(pv = 1000, rate = 0.10, n = 2)
#'
#' @export
calc_simple_interest <- function(pv, rate, n) {
  stopifnot(
    is.numeric(pv), length(pv) == 1,
    is.numeric(rate), length(rate) == 1,
    is.numeric(n), length(n) == 1,
    n >= 0
  )

  pv * (1 + rate * n)
}


#' Compound Interest
#'
#' Calculates the final value under compound interest.
#'
#' @param pv Present value.
#' @param rate Interest rate per period (decimal).
#' @param n Number of periods.
#'
#' @return Final value with compound interest.
#'
#' @examples
#' calc_compound_interest(pv = 1000, rate = 0.10, n = 2)
#'
#' @export
calc_compound_interest <- function(pv, rate, n) {
  stopifnot(
    is.numeric(pv), length(pv) == 1,
    is.numeric(rate), length(rate) == 1,
    is.numeric(n), length(n) == 1,
    n >= 0
  )

  pv * (1 + rate)^n
}


#' Effective Interest Rate
#'
#' Converts a nominal interest rate into an effective rate.
#'
#' @param nominal_rate Nominal interest rate (decimal).
#' @param m Number of compounding periods per year.
#'
#' @return Effective interest rate.
#'
#' @examples
#' calc_effective_rate(nominal_rate = 0.12, m = 12)
#'
#' @export
calc_effective_rate <- function(nominal_rate, m) {
  stopifnot(
    is.numeric(nominal_rate), length(nominal_rate) == 1,
    is.numeric(m), length(m) == 1,
    m > 0
  )

  (1 + nominal_rate / m)^m - 1
}


#' Nominal Interest Rate
#'
#' Converts an effective interest rate into a nominal rate.
#'
#' @param effective_rate Effective interest rate (decimal).
#' @param m Number of compounding periods per year.
#'
#' @return Nominal interest rate.
#'
#' @examples
#' calc_nominal_rate(effective_rate = 0.1268, m = 12)
#'
#' @export
calc_nominal_rate <- function(effective_rate, m) {
  stopifnot(
    is.numeric(effective_rate), length(effective_rate) == 1,
    is.numeric(m), length(m) == 1,
    m > 0
  )

  m * ((1 + effective_rate)^(1 / m) - 1)
}
