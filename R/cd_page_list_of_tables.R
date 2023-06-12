#' Title page LaTeX code
#'
#' Generates 'asis' LaTeX code to create a title page
#'
#' @param color Character. Document subtitle.
#' @param text_color Character.
#'
#' @export
#'
cd_page_list_of_tables <- function() {
  indiedown_glue(
    read_tex("table_of_tables.tex")
  )
}
