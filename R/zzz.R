.onAttach <- function(libname, pkgname) {
  packageStartupMessage(
    cli::rule(line = 1, line_col = "blue"), "\n",
    "🇧🇷  ", cli::style_bold("brfinance"), " - Democratizing access to Brazilian economic data\n",
    cli::rule(line = 1, line_col = "blue"), "\n\n",

    cli::style_bold("📊 Download Economic Data:\n"),
    "  • ", cli::col_green("get_selic_rate()"), "    - SELIC interest rate (annual)\n",
    "  • ", cli::col_green("get_inflation_rate()"), " - IPCA inflation with YTD & 12-month rates\n",
    "  • ", cli::col_green("get_unemployment()"), "   - Quarterly unemployment rate\n",
    "  • ", cli::col_green("get_exchange_rate()"), "  - US Dollar exchange rate\n",
    "  • ", cli::col_green("get_cdi_rate()"), "      - CDI interbank rate\n",
    "  • ", cli::col_green("get_gdp_growth()"), "    - Quarterly GDP growth\n\n",

    cli::style_bold("📈 Visualize Data:\n"),
    "  • ", cli::col_blue("plot_selic_rate()"), "    - Plot SELIC evolution\n",
    "  • ", cli::col_blue("plot_unemployment()"), "  - Plot unemployment trends\n",
    "  • ", cli::col_blue("More plots coming soon!"), "\n\n",

    cli::style_bold("🌐 Key Features:\n"),
    "  • ", cli::col_yellow("Set language = 'pt'"), " for Portuguese column names\n",
    "  • ", cli::col_yellow("Flexible date formats"), " (YYYY, YYYY-MM, YYYY-MM-DD)\n",
    "  • ", cli::col_yellow("Automatic data labels"), " with labelled package\n",
    "  • ", cli::col_yellow("BCB SGS API integration"), " - reliable data source\n\n",

    "🐛 Report issues: ", cli::style_italic("https://github.com/efram2/brfinance/issues\n\n"),

    cli::style_italic("Developed by "), cli::style_bold("Joao Paulo dos Santos P. Barbosa"),
    cli::style_italic(" (efram2)\n"),
    cli::style_italic("Contribute: https://github.com/efram2/brfinance")
  )
}
