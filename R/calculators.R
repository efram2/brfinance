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

  if (rate == -1) {
    stop("Rate cannot be -1 (division by zero)")
  }

  fv / (1 + rate)^n
}

#' Future Value (FV) - Basic
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

#' Future Value Extended (with periodic payments)
#'
#' Calculates the future value with optional periodic payments.
#'
#' @param pv Present value.
#' @param rate Interest rate per period (decimal).
#' @param n Number of periods.
#' @param pmt Periodic payment (default = 0).
#' @param type Payment timing: 0 for end of period (ordinary annuity),
#' 1 for beginning of period (annuity due).
#'
#' @return Future value.
#'
#' @examples
#' calc_future_value_ext(pv = 1000, rate = 0.05, n = 10, pmt = 100)
#' calc_future_value_ext(pv = 0, rate = 0.01, n = 12, pmt = 500, type = 1)
#'
#' @export
calc_future_value_ext <- function(pv, rate, n, pmt = 0, type = 0) {
  stopifnot(
    is.numeric(pv), length(pv) == 1,
    is.numeric(rate), length(rate) == 1,
    is.numeric(n), length(n) == 1,
    is.numeric(pmt), length(pmt) == 1,
    n >= 0,
    type %in% c(0, 1)
  )

  if (rate == 0) {
    fv_pv <- pv
    fv_pmt <- pmt * n * (1 + rate * type)
    return(fv_pv + fv_pmt)
  }

  fv_pv <- pv * (1 + rate)^n

  if (pmt != 0) {
    fv_pmt <- pmt * ((1 + rate)^n - 1) / rate
    if (type == 1) {
      fv_pmt <- fv_pmt * (1 + rate)
    }
  } else {
    fv_pmt <- 0
  }

  fv_pv + fv_pmt
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
#' calc_effective_rate(nominal_rate = 0.12, m = 12) # 12% nominal monthly
#'
#' @export
calc_effective_rate <- function(nominal_rate, m) {
  stopifnot(
    is.numeric(nominal_rate), length(nominal_rate) == 1,
    is.numeric(m), length(m) == 1, m > 0
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
    is.numeric(m), length(m) == 1, m > 0
  )

  m * ((1 + effective_rate)^(1 / m) - 1)
}

#' Future Value of an Annuity
#'
#' Calculates the future value of a series of equal payments.
#'
#' @param pmt Payment amount per period.
#' @param rate Interest rate per period (decimal).
#' @param n Number of periods.
#' @param type Payment timing: 0 for end of period (ordinary annuity),
#' 1 for beginning of period (annuity due).
#'
#' @return Future value of the annuity.
#'
#' @examples
#' calc_fv_annuity(pmt = 100, rate = 0.05, n = 10, type = 0)
#' calc_fv_annuity(pmt = 100, rate = 0.05, n = 10, type = 1)
#'
#' @export
calc_fv_annuity <- function(pmt, rate, n, type = 0) {
  stopifnot(
    is.numeric(pmt), length(pmt) == 1,
    is.numeric(rate), length(rate) == 1,
    is.numeric(n), length(n) == 1,
    n > 0,
    type %in% c(0, 1)
  )

  if (rate == 0) {
    return(pmt * n * (1 + rate * type))
  }

  fv <- pmt * ((1 + rate)^n - 1) / rate

  if (type == 1) {
    fv <- fv * (1 + rate)
  }

  fv
}

#' Present Value of an Annuity
#'
#' Calculates the present value of a series of equal payments.
#'
#' @param pmt Payment amount per period.
#' @param rate Interest rate per period (decimal).
#' @param n Number of periods.
#' @param type Payment timing: 0 for end of period, 1 for beginning of period.
#'
#' @return Present value of the annuity.
#'
#' @examples
#' calc_pv_annuity(pmt = 100, rate = 0.05, n = 10)
#' calc_pv_annuity(pmt = 100, rate = 0.05, n = 10, type = 1)
#'
#' @export
calc_pv_annuity <- function(pmt, rate, n, type = 0) {
  stopifnot(
    is.numeric(pmt), length(pmt) == 1,
    is.numeric(rate), length(rate) == 1,
    is.numeric(n), length(n) == 1,
    n > 0,
    type %in% c(0, 1)
  )

  if (rate == 0) {
    return(pmt * n * (1 + rate * type))
  }

  pv <- pmt * (1 - (1 + rate)^-n) / rate

  if (type == 1) {
    pv <- pv * (1 + rate)
  }

  pv
}

#' Loan Payment (PMT)
#'
#' Calculates the periodic payment for a loan.
#'
#' @param pv Present value (loan amount).
#' @param rate Interest rate per period (decimal).
#' @param n Number of periods.
#' @param type Payment timing: 0 for end of period, 1 for beginning of period.
#'
#' @return Periodic payment amount.
#'
#' @examples
#' calc_pmt(pv = 10000, rate = 0.01, n = 12) # Loan de R$10k, 1% ao mês, 12 meses
#'
#' @export
calc_pmt <- function(pv, rate, n, type = 0) {
  stopifnot(
    is.numeric(pv), length(pv) == 1, pv > 0,
    is.numeric(rate), length(rate) == 1,
    is.numeric(n), length(n) == 1, n > 0,
    type %in% c(0, 1)
  )

  if (rate == 0) {
    return(pv / n)
  }

  pmt <- (pv * rate) / (1 - (1 + rate)^-n)

  if (type == 1) {
    pmt <- pmt / (1 + rate)
  }

  pmt
}

#' Interest Rate (RATE)
#'
#' Calculates the interest rate per period.
#'
#' @param n Number of periods.
#' @param pv Present value.
#' @param fv Future value.
#' @param pmt Payment per period (optional, default = 0).
#' @param type Payment timing: 0 for end of period, 1 for beginning of period.
#' @param guess Initial guess for the rate (default = 0.1).
#' @param max_iter Maximum number of iterations (default = 100).
#' @param tol Tolerance for convergence (default = 1e-8).
#'
#' @return Interest rate per period.
#'
#' @examples
#' calc_rate(n = 12, pv = -1000, fv = 2000)
#' calc_rate(n = 60, pv = -20000, fv = 0, pmt = 386.66)
#'
#' @export
calc_rate <- function(n, pv, fv = 0, pmt = 0, type = 0,
                      guess = 0.1, max_iter = 100, tol = 1e-8) {
  stopifnot(
    is.numeric(n), length(n) == 1, n > 0,
    is.numeric(pv), length(pv) == 1,
    is.numeric(fv), length(fv) == 1,
    is.numeric(pmt), length(pmt) == 1,
    type %in% c(0, 1),
    is.numeric(guess), length(guess) == 1
  )

  # Define the function whose root we want to find
  f <- function(r) {
    if (type == 1) {
      pmt_adj <- pmt * (1 + r)
    } else {
      pmt_adj <- pmt
    }

    if (r == 0) {
      pv * (1 + r)^n + pmt_adj * n + fv
    } else {
      pv * (1 + r)^n + pmt_adj * ((1 + r)^n - 1) / r + fv
    }
  }

  # Use secant method
  r0 <- guess
  r1 <- guess * 0.99

  f0 <- f(r0)
  f1 <- f(r1)

  for (i in 1:max_iter) {
    if (abs(f1) < tol) {
      return(r1)
    }

    r2 <- r1 - f1 * (r1 - r0) / (f1 - f0)

    r0 <- r1
    f0 <- f1
    r1 <- r2
    f1 <- f(r1)

    if (abs(r1 - r0) < tol) {
      return(r1)
    }
  }

  warning("Maximum iterations reached. Result may not be accurate.")
  return(r1)
}

#' Net Present Value (NPV)
#'
#' Calculates the net present value of a series of cash flows.
#'
#' @param rate Discount rate per period (decimal).
#' @param cashflows Vector of cash flows (first is typically negative investment).
#'
#' @return Net present value.
#'
#' @examples
#' calc_npv(rate = 0.1, cashflows = c(-1000, 300, 400, 500))
#'
#' @export
calc_npv <- function(rate, cashflows) {
  stopifnot(
    is.numeric(rate), length(rate) == 1,
    is.numeric(cashflows), length(cashflows) >= 1
  )

  if (rate == -1) {
    stop("Rate cannot be -1 (division by zero)")
  }

  n <- length(cashflows)
  times <- 0:(n - 1)
  sum(cashflows / (1 + rate)^times)
}

#' Internal Rate of Return (IRR)
#'
#' Calculates the internal rate of return of a series of cash flows.
#'
#' @param cashflows Vector of cash flows (first is typically negative investment).
#' @param guess Initial guess for IRR (default = 0.1).
#'
#' @return Internal rate of return.
#'
#' @examples
#' calc_irr(cashflows = c(-1000, 300, 400, 500))
#'
#' @export
calc_irr <- function(cashflows, guess = 0.1) {
  stopifnot(
    is.numeric(cashflows), length(cashflows) >= 2,
    is.numeric(guess), length(guess) == 1
  )

  f <- function(r) calc_npv(r, cashflows)

  lower <- -0.9999
  upper <- 10

  f_lower <- f(lower)
  f_upper <- f(upper)

  if (f_lower * f_upper > 0) {
    lower <- -0.9
    upper <- 2
    for (j in 1:20) {
      f_lower <- f(lower)
      f_upper <- f(upper)
      if (f_lower * f_upper <= 0) break
      upper <- upper * 2
    }
  }

  for (i in 1:100) {
    mid <- (lower + upper) / 2
    f_mid <- f(mid)

    if (abs(f_mid) < 1e-8) {
      return(mid)
    }

    if (f_lower * f_mid < 0) {
      upper <- mid
      f_upper <- f_mid
    } else {
      lower <- mid
      f_lower <- f_mid
    }

  }

  warning("IRR calculation may not be precise")
  return((lower + upper) / 2)
}

#' Amortization Schedule
#'
#' Generates an amortization schedule for a loan.
#'
#' @param pv Loan amount.
#' @param rate Interest rate per period (decimal).
#' @param n Number of periods.
#' @param type Payment timing: 0 for end of period, 1 for beginning of period.
#'
#' @return Data frame with amortization schedule.
#'
#' @examples
#' calc_amortization_schedule(pv = 10000, rate = 0.01, n = 12)
#'
#' @export
calc_amortization_schedule <- function(pv, rate, n, type = 0) {
  stopifnot(
    is.numeric(pv), length(pv) == 1, pv > 0,
    is.numeric(rate), length(rate) == 1, rate >= 0,
    is.numeric(n), length(n) == 1, n > 0,
    type %in% c(0, 1)
  )

  pmt <- calc_pmt(pv, rate, n, type)

  schedule <- data.frame(
    Period = integer(n),
    Beginning_Balance = numeric(n),
    Payment = numeric(n),
    Interest = numeric(n),
    Principal = numeric(n),
    Ending_Balance = numeric(n)
  )

  balance <- pv

  for (i in 1:n) {
    interest <- balance * rate
    principal <- pmt - interest
    ending_balance <- balance - principal

    if (i == n) {
      principal <- balance
      pmt <- principal + interest
      ending_balance <- 0
    }

    schedule[i, ] <- c(i, balance, pmt, interest, principal, ending_balance)

    balance <- ending_balance
  }

  return(schedule)
}

#' Continuous Compounding
#'
#' Calculates the future value with continuous compounding.
#'
#' @param pv Present value.
#' @param rate Nominal annual interest rate (decimal).
#' @param t Time in years.
#'
#' @return Future value with continuous compounding.
#'
#' @examples
#' calc_continuous_compounding(pv = 1000, rate = 0.05, t = 2)
#'
#' @export
calc_continuous_compounding <- function(pv, rate, t) {
  stopifnot(
    is.numeric(pv), length(pv) == 1,
    is.numeric(rate), length(rate) == 1,
    is.numeric(t), length(t) == 1, t >= 0
  )

  pv * exp(rate * t)
}

#' Present Value with Continuous Compounding
#'
#' Calculates the present value with continuous compounding.
#'
#' @param fv Future value.
#' @param rate Nominal annual interest rate (decimal).
#' @param t Time in years.
#'
#' @return Present value with continuous compounding.
#'
#' @examples
#' calc_pv_continuous(fv = 1105.17, rate = 0.05, t = 2)
#'
#' @export
calc_pv_continuous <- function(fv, rate, t) {
  stopifnot(
    is.numeric(fv), length(fv) == 1,
    is.numeric(rate), length(rate) == 1,
    is.numeric(t), length(t) == 1, t >= 0
  )

  fv * exp(-rate * t)
}

#' Rule of 72
#'
#' Estimates the number of years required to double an investment.
#'
#' @param rate Annual interest rate (decimal).
#'
#' @return Approximate years to double.
#'
#' @examples
#' rule_of_72(rate = 0.08)
#'
#' @export
rule_of_72 <- function(rate) {
  stopifnot(
    is.numeric(rate), length(rate) == 1, rate > 0
  )

  72 / (rate * 100)
}

#' Rule of 114
#'
#' Estimates the number of years required to triple an investment.
#'
#' @param rate Annual interest rate (decimal).
#'
#' @return Approximate years to triple.
#'
#' @examples
#' rule_of_114(rate = 0.08)
#'
#' @export
rule_of_114 <- function(rate) {
  stopifnot(
    is.numeric(rate), length(rate) == 1, rate > 0
  )

  114 / (rate * 100)
}

#' Number of Periods (NPER)
#'
#' Calculates the number of periods for an investment.
#'
#' @param pv Present value.
#' @param fv Future value.
#' @param rate Interest rate per period (decimal).
#' @param pmt Payment per period (optional, default = 0).
#' @param type Payment timing: 0 for end of period, 1 for beginning of period.
#'
#' @return Number of periods.
#'
#' @examples
#' calc_nper(pv = -1000, fv = 2000, rate = 0.05)
#' calc_nper(pv = 0, fv = 100000, rate = 0.01, pmt = -500)
#'
#' @export
calc_nper <- function(pv, fv = 0, rate, pmt = 0, type = 0) {
  stopifnot(
    is.numeric(pv), length(pv) == 1,
    is.numeric(fv), length(fv) == 1,
    is.numeric(rate), length(rate) == 1,
    is.numeric(pmt), length(pmt) == 1,
    type %in% c(0, 1),
    rate != -1
  )

#  Case 1: Only PV and FV (no payments)
  if (pmt == 0) {
    if (pv == 0) {
      stop("PV cannot be zero when PMT is zero")
    }
    if (rate == 0) {
      stop("Rate cannot be zero when PMT is zero")
    }
    return(log(fv / pv) / log(1 + rate))
  }

# Case 2: With payments
  if (rate == 0) {
    return(-(fv + pv) / pmt)
  }

  if (type == 1) {
    pmt_adj <- pmt * (1 + rate)
  } else {
    pmt_adj <- pmt
  }

  log((pmt_adj - fv * rate) / (pmt_adj + pv * rate)) / log(1 + rate)
}
