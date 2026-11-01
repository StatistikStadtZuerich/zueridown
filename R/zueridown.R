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

#' R Markdown output format backed by indiedown assets
#'
#' Wraps [rmarkdown::pdf_document()] and injects the asset package's
#' `preamble.tex` and pre-processor. Downstream packages such as `zueridown`
#' call this from their own output format (see [zueridown()]).
#'
#' The function is defined in `R/import-standalone-indiedown.R`,
#' which does not export it.
#'
#' @param includes Named list as produced by [rmarkdown::includes()]. The
#'   asset `preamble.tex` is added as `in_header` unless one is already set.
#' @param ... Passed on to [rmarkdown::pdf_document()].
#'
#' @return An R Markdown output format object.
#'
#' @name indiedown_pdf_document_with_asset
#' @usage indiedown_pdf_document_with_asset(includes = NULL, ...)
#' @export indiedown_pdf_document_with_asset
NULL
