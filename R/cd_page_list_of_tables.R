#' List of tables
#'
#' Generates 'asis' LaTeX code for the list of tables.
#'
#' @export
#'
cd_page_list_of_tables <- function() {
  indiedown_glue(
    read_tex("table_of_tables.tex")
  )
}
