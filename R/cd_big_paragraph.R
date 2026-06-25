#' Lead paragraph
#'
#' Generates 'asis' LaTeX code for a large, emphasised lead paragraph
#' (for example a summary at the start of a report).
#'
#' @param text Character. The paragraph text.
#'
#' @export
#'
cd_big_paragraph <- function(text = default("")) {
  indiedown_glue(
    read_tex("big_paragraph.tex")
  )
}
