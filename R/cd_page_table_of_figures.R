#' List of figures
#'
#' Generates 'asis' LaTeX code for the list of figures.
#'
#' @export
#'
cd_page_table_of_figures <- function() {
  indiedown_glue(
    read_tex("table_of_figures.tex")
  )
}
