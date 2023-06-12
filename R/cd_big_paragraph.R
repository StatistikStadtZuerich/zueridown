#' Title page LaTeX code
#'
#' Generates 'asis' LaTeX code to create a title page
#'
#' @param color Character. Document subtitle.
#' @param text_color Character.
#'
#' @export
#'
cd_big_paragraph <- function(text = default("")) {
  indiedown_glue(
    read_tex("big_paragraph.tex")
  )
}
