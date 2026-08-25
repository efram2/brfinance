.onAttach <- function(libname, pkgname) {
  packageStartupMessage(
    "brfinance: Brazilian macroeconomic data and financial tools\n",
    "Data from the Central Bank of Brazil (SGS) and IBGE, plus a set of financial calculators.\n\n",

    "Get started:\n",
    "  ?brfinance                    Package overview\n",
    "  browseVignettes('brfinance')  Worked examples\n\n",

    "Issues & contributions: https://github.com/efram2/brfinance"
  )
}
