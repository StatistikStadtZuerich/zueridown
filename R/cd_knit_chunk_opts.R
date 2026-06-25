#' Rmarkdown arguments
#'
#' Configuration of arguments to set up chunks. You can check arguments and
#' options in the documentation of the knitr package at
#' \href{https://yihui.org/knitr/options/#chunk-options}{https://yihui.org/knitr/options/#chunk-options}
#'
#' @param metadata Pass Rmarkdown arguments from yml header for instance title,
#' twocolumn, or lang.
#' @param fig.width,fig.height Numeric. Default figure width/height in inches.
#' When `NULL` (the default), sensible values are chosen from the `twocolumn`
#' and `wide` metadata fields.
#' @param fig.pos Character. LaTeX figure placement specifier. Default `"h"`.
#' @param cache Logical. Knitr chunk caching. Default `FALSE`.
#' @param message Logical. Show messages. Default `FALSE`.
#' @param echo Logical. Echo source code. Default `FALSE`.
#' @param tidy Logical. Reformat code. Default `FALSE`.
#'
#' @export
#'
cd_knit_chunk_opts <- function(
  metadata = rmarkdown::metadata,
  fig.width = NULL,
  fig.height = NULL,
  fig.pos = "h",
  cache = FALSE,
  message = FALSE,
  echo = FALSE,
  tidy = FALSE
) {
  if (isTRUE(metadata$twocolumn)) {
    fig.width <- default(fig.width, 4)
    fig.height <- default(fig.height, 3.5)
  } else {
    if (isTRUE(metadata$wide)) {
      fig.width <- default(fig.width, 8.5)
      fig.height <- default(fig.height, 3.38)
    } else {
      fig.width <- default(fig.width, 7.25)
      fig.height <- default(fig.height, 3.5)
    }
  }
  knitr::opts_chunk$set(
    fig.width = fig.width,
    fig.height = fig.height,
    fig.pos = "h",
    cache = FALSE,
    message = FALSE,
    echo = FALSE,
    tidy = FALSE
  )

  options(knitr.table.format = "latex")
}
