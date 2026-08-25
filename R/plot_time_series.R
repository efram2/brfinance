#' Internal function to generate standardized time series plots
#'
#' This function provides a flexible way to create time series plots with
#' consistent, elegant styling across the brfinance package.
#'
#' @param data Data frame/tibble with time series data
#' @param x_var Name of the column to use for x-axis (date/time variable)
#' @param y_var Name of the column to use for y-axis (value variable)
#' @param plot_type Type of plot: "line" (default), "step", "bar", "point"
#' @param title Plot title
#' @param subtitle Plot subtitle
#' @param x_label Label for x-axis (NULL for no label)
#' @param y_label Label for y-axis
#' @param caption Plot caption
#' @param color Line/bar color
#' @param point_color Color for point markers. Defaults to `color` (a
#'   slightly darker/contrasting shade is no longer forced automatically --
#'   callers that want a contrasting marker color should pass one explicitly,
#'   as `plot_series()`'s config table now does).
#' @param line_size Line thickness. Default is thinner (0.7) than earlier
#'   versions of this package for a cleaner, less "chart-junk" look.
#' @param point_size Point size when points are shown. Ignored when points
#'   end up hidden by the `show_points = "auto"` density rule.
#' @param date_breaks Break interval for date axis (e.g., "6 months")
#' @param date_labels Format for date labels (e.g., "%b/%Y")
#' @param y_suffix Suffix for y-axis labels (e.g., "%", "R$")
#' @param theme_base_size Base font size for theme
#' @param rotate_x_angle Angle for x-axis text (default: 45)
#' @param show_points Whether to show point markers on line/step plots.
#'   `"auto"` (the default) shows small "halo" markers only when the series
#'   is sparse enough for them to read as individual data points (<= 60 rows
#'   -- roughly monthly-or-coarser data) and hides them for dense daily
#'   series (SELIC, CDI, exchange rate, Ibovespa, ...), where one dot per
#'   observation just turns into visual noise, especially at small plot
#'   sizes. Pass `TRUE`/`FALSE` to force markers on or off regardless of
#'   density.
#' @param ... Additional arguments passed to ggplot2 geoms
#'
#' @return A ggplot2 object
#' @keywords internal
#' @noRd
#'
#' @examples
#' \donttest{
#' # Create example time series data
#' df <- data.frame(
#'   date = seq(as.Date("2020-01-01"), as.Date("2021-12-01"), by = "month"),
#'   value = cumsum(rnorm(24, 0.5, 1))
#' )
#'
#' # Line plot
#' p1 <- brfinance:::.plot_time_series(
#'   data = df,
#'   x_var = "date",
#'   y_var = "value",
#'   plot_type = "line",
#'   title = "Example Time Series",
#'   y_label = "Index",
#'   y_suffix = ""
#' )
#'
#' print(p1)
#'
#' # Bar plot
#' p2 <- brfinance:::.plot_time_series(
#'   data = df,
#'   x_var = "date",
#'   y_var = "value",
#'   plot_type = "bar",
#'   title = "Bar Version",
#'   y_label = "Index"
#' )
#'
#' print(p2)
#' }
.plot_time_series <- function(data,
                              x_var,
                              y_var,
                              plot_type = c("line", "step", "bar", "point"),
                              title = NULL,
                              subtitle = NULL,
                              x_label = NULL,
                              y_label = NULL,
                              caption = NULL,
                              color = NULL,
                              point_color = NULL,
                              line_size = 0.7,
                              point_size = 1.8,
                              date_breaks = "6 months",
                              date_labels = "%b/%Y",
                              y_suffix = NULL,
                              theme_base_size = 14,
                              rotate_x_angle = 45,
                              show_points = "auto") {

  plot_type <- match.arg(plot_type)

  if (is.null(color)) {
    color <- "#1B4F72"  # deep, muted "financial" blue -- default when a
    # caller doesn't specify one (plot_series()'s
    # config table always does)
  }

  if (is.null(point_color)) {
    point_color <- color
  }

  # === POINT DENSITY RULE ===
  # A dot per observation reads as "data points" on a ~12-60 row monthly
  # series, but on a multi-year daily series (thousands of rows) it just
  # becomes a solid smear that looks worse the smaller the plot is
  # rendered. "auto" resolves to visible markers only below that rowcount.
  n_obs <- nrow(data)

  points_visible <- if (identical(show_points, "auto")) {
    plot_type %in% c("line", "step") && n_obs <= 60
  } else {
    isTRUE(show_points) && plot_type %in% c("line", "step")
  }

  p <- ggplot2::ggplot(
    data,
    ggplot2::aes(
      x = !!ggplot2::sym(x_var),
      y = !!ggplot2::sym(y_var)
    )
  )

  if (plot_type %in% c("line", "step")) {
    geom_fun <- if (plot_type == "line") ggplot2::geom_line else ggplot2::geom_step

    p <- p + geom_fun(color = color, linewidth = line_size, lineend = "round")

    if (points_visible) {
      # "Halo" markers: a white-filled ring instead of a solid dot reads as
      # lighter and more refined, especially with several markers close
      # together -- the outline carries the color, the center stays open.
      p <- p + ggplot2::geom_point(
        shape = 21,
        color = point_color,
        fill = "white",
        size = point_size,
        stroke = 0.9
      )
    }
  }

  if (plot_type == "bar") {
    p <- p + ggplot2::geom_col(fill = color, width = 0.7)
  }

  if (plot_type == "point") {
    p <- p + ggplot2::geom_point(
      color = color,
      size = point_size,
      alpha = 0.85
    )
  }

  p <- p +
    ggplot2::theme_minimal(base_size = theme_base_size) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(face = "bold", hjust = 0.5, size = ggplot2::rel(1.05)),
      plot.subtitle = ggplot2::element_text(hjust = 0.5, color = "grey35", size = ggplot2::rel(0.85)),
      plot.caption = ggplot2::element_text(color = "grey45", size = ggplot2::rel(0.65), face = "italic"),
      axis.title = ggplot2::element_text(color = "grey25", size = ggplot2::rel(0.85)),
      axis.text = ggplot2::element_text(color = "grey35"),
      axis.text.x = ggplot2::element_text(
        angle = rotate_x_angle,
        hjust = 1,
        vjust = if (rotate_x_angle == 0) 0.5 else 1
      ),
      panel.grid.major = ggplot2::element_line(color = "grey92", linewidth = 0.35),
      panel.grid.minor = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank()
    )

  if (inherits(data[[x_var]], c("Date", "POSIXct", "POSIXt"))) {
    p <- p + ggplot2::scale_x_date(
      date_breaks = date_breaks,
      date_labels = date_labels
    )
  }

  if (!is.null(y_suffix)) {
    p <- p + ggplot2::scale_y_continuous(
      labels = scales::label_number(suffix = y_suffix)
    )
  }

  p <- p + ggplot2::labs(
    title = title,
    subtitle = subtitle,
    x = x_label,
    y = y_label,
    caption = caption
  )

  return(p)
}
