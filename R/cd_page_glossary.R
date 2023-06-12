#' Title page LaTeX code
#'
#' Generates 'asis' LaTeX code to create the glossary.
#'
#' @export
#'
cd_page_glossary <- function() {
  indiedown_path <- indiedown_path_tex()

  indiedown_glue(
    read_tex("page_glossary.tex")
  )
}
