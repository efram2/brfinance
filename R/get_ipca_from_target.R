#' Get IPCA vs. Inflation Target Gap
#'
#' Compares 12-month accumulated IPCA inflation against the official
#' inflation target set annually by the CMN (Conselho Monetário Nacional),
#' and returns both series plus the gap between them (positive means
#' inflation is running above target).
#'
#' @param start_date Start date for the data period. Accepts multiple formats:
#'   - `"YYYY"` for year only (e.g., `"2020"` becomes `"2020-01-01"`)
#'   - `"YYYY-MM"` for year and month (e.g., `"2020-06"` becomes `"2020-06-01"`)
#'   - `"YYYY-MM-DD"` for a specific date (e.g., `"2020-06-15"`)
#'   - `NULL` defaults to `"2020-01-01"`
#' @param end_date End date for the data period. Accepts the same formats as `start_date`:
#'   - `"YYYY"` (e.g., `"2023"` becomes `"2023-12-31"`)
#'   - `"YYYY-MM"` (e.g., `"2023-12"` becomes the last day of December 2023)
#'   - `"YYYY-MM-DD"` for a specific date
#'   - `NULL` defaults to the current date (today)
#' @param language Language for the `labelled` variable descriptions attached
#'   to the returned data.frame ("eng" or "pt").
#' @param labels Logical indicating whether to add variable labels using the
#'   `labelled` package.
#'
#' @return A data.frame with columns:
#' \describe{
#'   \item{date}{Reference date (monthly)}
#'   \item{ipca_12m}{IPCA inflation accumulated over the trailing 12 months (%)}
#'   \item{target}{Official CMN inflation target for that calendar year (%)}
#'   \item{gap}{`ipca_12m - target`, in percentage points}
#' }
#'
#' @note
#' **Series used**: SGS 13522 ("IPCA - Variação acumulada em 12 meses"),
#' monthly, and SGS 13521 ("Meta para a inflação", set by the CMN), which
#' has annual frequency — one value per calendar year. The target is
#' broadcast to every month of its year via a left join on the year, so it
#' lines up with the monthly `ipca_12m` series. If the CMN has not yet set a
#' target for the most recent year in the requested window, `target`/`gap`
#' will be `NA` for those months rather than silently reusing an old value.
#'
#' @examples
#' \donttest{
#'   df <- get_ipca_from_target()
#'   df2 <- get_ipca_from_target("2015", "2024", language = "pt")
#'   }
#'
#' @export
get_ipca_from_target <- function(start_date = NULL,
                                 end_date = NULL,
                                 language = "eng",
                                 labels = TRUE) {

  # === PARAMETER VALIDATION ===
  if (!is.character(language) || length(language) != 1) {
    stop("'language' must be a single character string ('eng' or 'pt')", call. = FALSE)
  }

  language <- tolower(language)
  if (!language %in% c("eng", "pt")) {
    stop("'language' must be either 'eng' (English) or 'pt' (Portuguese)", call. = FALSE)
  }

  if (!is.logical(labels) || length(labels) != 1) {
    stop("'labels' must be a single logical value (TRUE or FALSE)", call. = FALSE)
  }

  if (is.null(start_date)) {
    start_date <- "2020-01-01"
  }

  end_date <- end_date

  # === FUNCTION BODY ===
  # Declare global variables for dplyr operations
  value <- ano <- ipca_12m <- target <- gap <- NULL

  # SGS 13522 = IPCA acumulado em 12 meses (mensal, %)
  ipca_12m_df <- .get_sgs_series(
    series_id = 13522,
    start_date = start_date,
    end_date = end_date
  ) |>
    dplyr::rename(ipca_12m = value)

  # SGS 13521 = Meta para a inflacao definida pelo CMN (anual, %)
  meta_df <- .get_sgs_series(
    series_id = 13521,
    start_date = start_date,
    end_date = end_date
  ) |>
    dplyr::mutate(ano = as.integer(format(date, "%Y"))) |>
    dplyr::select(ano, target = value)

  # Broadcast the annual target across every month of its calendar year
  data <- ipca_12m_df |>
    dplyr::mutate(ano = as.integer(format(date, "%Y"))) |>
    dplyr::left_join(meta_df, by = "ano") |>
    dplyr::mutate(gap = ipca_12m - target) |>
    dplyr::select(date, ipca_12m, target, gap) |>
    dplyr::arrange(date)

  # === VARIABLE LABELS ===
  if (isTRUE(labels) && requireNamespace("labelled", quietly = TRUE)) {

    if (language == "pt") {
      data <- labelled::set_variable_labels(
        data,
        date = "Data de referencia",
        ipca_12m = "IPCA acumulado em 12 meses (%)",
        target = "Meta de inflacao definida pelo CMN (% a.a.)",
        gap = "Diferenca entre IPCA 12m e a meta (p.p.)"
      )
    } else {
      data <- labelled::set_variable_labels(
        data,
        date = "Reference date",
        ipca_12m = "IPCA inflation, 12-month accumulated (%)",
        target = "CMN inflation target (% p.a.)",
        gap = "Gap between 12m IPCA and target (p.p.)"
      )
    }
  }

  return(data)
}
