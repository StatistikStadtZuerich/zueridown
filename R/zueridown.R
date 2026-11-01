#' zueridown PDF output format
#'
#' R Markdown output format for the city of Zurich corporate design. A thin
#' wrapper around [indiedown_pdf_document_with_asset()] that fixes the syntax
#' highlighting style and the LaTeX engine (`xelatex`, required for the
#' bundled fonts).
#'
#' Unless the document sets `mainfont`, the main font is TeX Gyre Heros,
#' a Helvetica clone that ships with the package
#' and is loaded by file name from its installation directory.
#' The output therefore does not depend on the fonts installed on the system,
#' and no font needs to be installed.
#' Any `mainfontoptions` set in the document are appended
#' to the options that locate the font files.
#'
#' @param ... Passed on to [indiedown_pdf_document_with_asset()] and, in turn,
#'   to [rmarkdown::pdf_document()].
#'
#' @return An R Markdown output format object.
#'
#' @export
zueridown <- function(...) {
  indiedown_pdf_document_with_asset(
    highlight = "pygments",
    latex_engine = "xelatex",
    ...
  )
}
