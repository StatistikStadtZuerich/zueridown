#' Plot/table title and subtitle
#'
#' Creates a title and a subtitle above the plot /table.
#' Special symbols must be preceded by a \\\\ (ex. \\\\&)
#'
#' @param caption Character. Written in bold
#' @param subcaption Character. If you want to have it on more lines,
#' insert the latex command 'newline' in the code.
#' @param label Character. Optional LaTeX label for cross-referencing the
#' figure or table (for example `"fig:figura1"`).
#'
#' @export

cd_caption_subcaption <- function(
  caption = default(""),
  subcaption = default(""),
  label = default("")
) {
  indiedown_path <- indiedown_path_tex()

  indiedown_glue(
    read_tex("caption_fig.tex")
  )
}
