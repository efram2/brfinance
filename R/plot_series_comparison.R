#' Compare multiple financial/time series indices
#'
#' Plots multiple time series on the same chart for comparison.
#'
#' @param data_list Named list of data frames, each returned by a get_* function
#' @param y_vars Vector of column names containing the values to plot from each data frame
#' @param date_vars Vector of column names containing dates from each data frame
#' @param language Language for labels: "pt" (Portuguese) or "eng" (English)
#' @param scale_type Scaling applied to the series:
#' \describe{
#'   \item{"none"}{Plots raw values as provided}
#'   \item{"index"}{Indexes all series to 100 at the first observation}
#'   \item{"percent_change"}{Plots percentage change relative to the first observation}
#' }
#' @param title Plot title
#' @param subtitle Plot subtitle
#' @param y_label Y-axis label
#' @param caption Plot caption
#' @param colors Vector of colors for each series
#' @param line_types Vector of line types for each series
#' @param show_legend Whether to show the legend (default: TRUE)
#' @param legend_position Position of legend ("bottom", "top", "left", "right", or "none")
#' @param dual_axis Logical. If `TRUE`, plots exactly 2 series on separate
#'   y-axes (a primary axis on the left for the first series, a secondary
#'   axis on the right for the second) instead of overlaying them on one
#'   scale. Useful for comparing series with very different units, e.g.
#'   SELIC (%) vs. the exchange rate (R$/US$). Requires `length(data_list) == 2`
#'   and is incompatible with `scale_type != "none"`, since the whole point of
#'   a dual axis is to preserve each series' native scale.
#'
#' @return A ggplot2 object
#'
#' @examples
#' \donttest{
#' # Example comparing multiple series
#' selic <- get_selic_rate(2020, 2024)
#' ipca <- get_ipca_from_target(2020, 2024)
#'
#' comparison_plot <- plot_series_comparison(
#'   data_list = list(SELIC = selic, IPCA = ipca),
#'   y_vars = c("value", "ipca_12m"),
#'   date_vars = c("date", "date"),
#'   scale_type = "index",
#'   title = "Comparison of Brazilian Economic Indicators",
#'   y_label = "Index (2020-01 = 100)",
#'   language = "eng"
#' )
#' print(comparison_plot)
#'
#' # Same two series, but on their native scales via a dual axis
#' dual_plot <- plot_series_comparison(
#'   data_list = list(SELIC = selic, `Exchange Rate` = get_exchange_rate(2020, 2024)),
#'   y_vars = c("value", "value"),
#'   date_vars = c("date", "date"),
#'   dual_axis = TRUE
#' )
#' print(dual_plot)
#' }
#'
#' @export
plot_series_comparison <- function(data_list,
                                   y_vars,
                                   date_vars,
                                   language = "eng",
                                   scale_type = c("none", "index", "percent_change"),
                                   title = NULL,
                                   subtitle = NULL,
                                   y_label = NULL,
                                   caption = NULL,
                                   colors = NULL,
                                   line_types = NULL,
                                   show_legend = TRUE,
                                   legend_position = "bottom",
                                   dual_axis = FALSE) {

  # === PARAMETER VALIDATION ===
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("The 'ggplot2' package is required. Install it with install.packages('ggplot2').")
  }

  if (!requireNamespace("dplyr", quietly = TRUE)) {
    stop("The 'dplyr' package is required. Install it with install.packages('dplyr').")
  }

  if (!requireNamespace("tidyr", quietly = TRUE)) {
    stop("The 'tidyr' package is required. Install it with install.packages('tidyr').")
  }

  # === FUNCTION BODY ===
  # Declare global variables for dplyr operations
  value <- series <- NULL

  scale_type <- match.arg(scale_type)

  # Validate inputs
  n_series <- length(data_list)
  if (length(y_vars) != n_series || length(date_vars) != n_series) {
    stop("Length of data_list, y_vars, and date_vars must be the same")
  }

  if (isTRUE(dual_axis)) {
    if (n_series != 2) {
      stop("'dual_axis = TRUE' requires exactly 2 series in 'data_list'.", call. = FALSE)
    }
    if (scale_type != "none") {
      stop(
        "'dual_axis = TRUE' is incompatible with scale_type != 'none' -- ",
        "the point of a dual axis is to keep each series on its own native scale.",
        call. = FALSE
      )
    }
  }

  if (is.null(names(data_list))) {
    names(data_list) <- paste0("Series_", seq_len(n_series))
  }

  # Prepare each series
  prepared_series <- list()

  for (i in seq_len(n_series)) {
    df <- data_list[[i]]
    series_name <- names(data_list)[i]

    # Select and rename columns
    df_prep <- df |>
      dplyr::select(
        date = !!dplyr::sym(date_vars[i]),
        value = !!dplyr::sym(y_vars[i])
      ) |>
      dplyr::mutate(series = series_name)

    # Apply scaling if requested
    if (scale_type == "index") {
      df_prep <- df_prep |>
        dplyr::mutate(value = 100 * value / value[1])
    } else if (scale_type == "percent_change") {
      df_prep <- df_prep |>
        dplyr::mutate(value = 100 * (value / value[1] - 1))
    }

    prepared_series[[i]] <- df_prep
  }

  # Combine all series
  combined_data <- dplyr::bind_rows(prepared_series)

  # === DUAL AXIS BRANCH ===
  # Two series, each kept on its own native scale: the second series is
  # linearly rescaled onto the first series' range purely for plotting
  # position, then a ggplot2 secondary axis (`sec_axis`) maps back to its
  # real values for the labels -- the data itself is never altered.
  if (isTRUE(dual_axis)) {

    series_names <- names(data_list)
    s1 <- prepared_series[[1]]
    s2 <- prepared_series[[2]]

    range1 <- range(s1$value, na.rm = TRUE)
    range2 <- range(s2$value, na.rm = TRUE)

    if (diff(range2) == 0) {
      stop(
        "Cannot build a dual axis: the second series ('", series_names[2],
        "') is constant over the requested period.", call. = FALSE
      )
    }

    scale_factor <- diff(range1) / diff(range2)
    offset <- range1[1] - range2[1] * scale_factor

    s2_scaled <- s2 |>
      dplyr::mutate(value = value * scale_factor + offset)

    dual_data <- dplyr::bind_rows(s1, s2_scaled)

    dual_colors <- if (!is.null(colors)) colors[1:2] else c(.BRFINANCE_MARKET_BLUE, .BRFINANCE_MARKET_RED)

    if (is.null(title)) {
      title <- if (language == "pt") {
        "Comparacao de Indicadores Economicos (eixo duplo)"
      } else {
        "Comparison of Economic Indicators (dual axis)"
      }
    }

    p <- ggplot2::ggplot(dual_data, ggplot2::aes(x = date, y = value, color = series)) +
      ggplot2::geom_line(linewidth = 0.7, lineend = "round") +
      ggplot2::scale_color_manual(values = dual_colors) +
      ggplot2::scale_y_continuous(
        name = series_names[1],
        sec.axis = ggplot2::sec_axis(
          trans = ~ (. - offset) / scale_factor,
          name = series_names[2]
        )
      ) +
      ggplot2::theme_minimal(base_size = 14) +
      ggplot2::theme(
        plot.title = ggplot2::element_text(face = "bold", hjust = 0.5, size = ggplot2::rel(1.05)),
        plot.subtitle = ggplot2::element_text(hjust = 0.5, color = "grey35", size = ggplot2::rel(0.85)),
        plot.caption = ggplot2::element_text(color = "grey45", size = ggplot2::rel(0.65), face = "italic"),
        legend.position = if (show_legend) legend_position else "none",
        axis.text.x = ggplot2::element_text(angle = 45, hjust = 1),
        axis.title.y.left = ggplot2::element_text(color = dual_colors[1]),
        axis.title.y.right = ggplot2::element_text(color = dual_colors[2]),
        panel.grid.major = ggplot2::element_line(color = "grey92", linewidth = 0.35),
        panel.grid.minor = ggplot2::element_blank(),
        axis.ticks = ggplot2::element_blank()
      ) +
      ggplot2::labs(
        title = title,
        subtitle = subtitle,
        x = NULL,
        caption = caption,
        color = "Indicator"
      )

    if (inherits(dual_data$date, c("Date", "POSIXct", "POSIXt"))) {
      p <- p + ggplot2::scale_x_date(date_breaks = "6 months", date_labels = "%b/%Y")
    }

    return(p)
  }

  # Set default colors if not provided -- leads with the same muted
  # financial blue/red used across plot_cdi_rate()/plot_selic_rate()/etc.,
  # then falls back to complementary tones for additional series.
  if (is.null(colors)) {
    colors <- c(.BRFINANCE_MARKET_BLUE, .BRFINANCE_MARKET_RED, "#2C7A5B",
                "#C17817", "#5B4B8A", "#8C5A3C", "#5C8FA6",
                "#B0708A")[seq_len(n_series)]
  }

  if (is.null(line_types)) {
    line_types <- rep("solid", n_series)
  }

  # Create plot
  p <- ggplot2::ggplot(combined_data,
                       ggplot2::aes(x = date, y = value,
                                    color = series, linetype = series)) +
    ggplot2::geom_line(linewidth = 0.7, lineend = "round") +
    ggplot2::scale_color_manual(values = colors) +
    ggplot2::scale_linetype_manual(values = line_types) +
    ggplot2::theme_minimal(base_size = 14) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(face = "bold", hjust = 0.5, size = ggplot2::rel(1.05)),
      plot.subtitle = ggplot2::element_text(hjust = 0.5, color = "grey35", size = ggplot2::rel(0.85)),
      plot.caption = ggplot2::element_text(color = "grey45", size = ggplot2::rel(0.65), face = "italic"),
      legend.position = if (show_legend) legend_position else "none",
      axis.text.x = ggplot2::element_text(angle = 45, hjust = 1),
      panel.grid.major = ggplot2::element_line(color = "grey92", linewidth = 0.35),
      panel.grid.minor = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank()
    )

  # Format x-axis if it's a date
  if (inherits(combined_data$date, c("Date", "POSIXct", "POSIXt"))) {
    p <- p + ggplot2::scale_x_date(
      date_breaks = "6 months",
      date_labels = "%b/%Y"
    )
  }

  # Add suffix based on scale type
  if (scale_type == "index") {
    p <- p + ggplot2::scale_y_continuous(labels = scales::label_number())
    if (is.null(y_label)) y_label <- "Index"
  } else if (scale_type == "percent_change") {
    p <- p + ggplot2::scale_y_continuous(labels = scales::label_number(suffix = "%"))
    if (is.null(y_label)) y_label <- "Percent Change"
  } else {
    p <- p + ggplot2::scale_y_continuous(labels = scales::label_number())
  }

  # Set default title if not provided
  if (is.null(title)) {
    if (language == "eng") {
      title <- "Comparison of Economic Indicators"
    } else {
      title <- "Comparacao de Indicadores Economicos"
    }
  }

  # Add labels
  p <- p + ggplot2::labs(
    title = title,
    subtitle = subtitle,
    x = NULL,
    y = y_label,
    caption = caption,
    color = "Indicator",
    linetype = "Indicator"
  )

  return(p)
}
