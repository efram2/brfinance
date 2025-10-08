.onAttach <- function(libname, pkgname) {
  packageStartupMessage(
    "brfinance — Democratizing access to Brazilian economic data 🇧🇷\n",
    "Use get_*() functions to download datasets (e.g., get_unemployment()).\n",
    "Use plot_*() functions to visualize them (e.g., plot_unemployment()).\n\n",
    "Set language = 'pt' for Portuguese labels. Enjoy!\n",

    "Developed by João Paulo dos Santos P. Barbosa.\n",
    "To learn more: https://github.com/efram2/brfinance"
  )
}
