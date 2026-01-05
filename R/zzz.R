.onAttach <- function(libname, pkgname) {
  packageStartupMessage(
    "brfinance: Brazilian macroeconomic data and financial tools\n",
    "------------------------------------------------------------\n\n",

    "Data access functions (examples):\n",
    "  get_selic_rate()      SELIC interest rate\n",
    "  get_inflation_rate()  IPCA inflation indicators\n",
    "  get_unemployment()    Unemployment rate (PNAD Continua)\n",
    "  get_exchange_rate()   Exchange rates\n",
    "  get_cdi_rate()        CDI interbank rate\n",
    "  get_gdp_growth()      GDP growth rates\n\n",

    "Visualization helpers:\n",
    "  plot_selic_rate()\n",
    "  plot_unemployment()\n",
    "  plot_series_comparison()\n\n",

    "General features:\n",
    "  Flexible date inputs: YYYY, YYYY-MM, YYYY-MM-DD\n",
    "  Language support: English (default) or Portuguese\n",
    "  Consistent outputs across data sources\n\n",

    "See documentation:\n",
    "  ?brfinance\n",
    "  browseVignettes('brfinance')\n\n",

    "Issues & contributions:\n",
    "  https://github.com/efram2/brfinance"
  )
}
