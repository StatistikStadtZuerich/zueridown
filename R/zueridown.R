#' zueridown PDF output format
#'
#' R Markdown output format for the city of Zurich corporate design. A thin
#' wrapper around [indiedown_pdf_document_with_asset()] that fixes the syntax
#' highlighting style and the LaTeX engine (`xelatex`, required for the
#' bundled fonts).
#'
#' The main font is Helvetica Neue LT Pro, the font of the corporate design,
#' if it is installed: 65 Medium as regular and 85 Heavy as bold.
#' The font is licensed and does not ship with the package.
#' It is loaded from its font files, which are found
#' if the font is installed for the current user or for all users.
#' Users who cannot install fonts can copy the font files to a folder
#' and set the option `zueridown.font_path` to that folder, e.g. in `.Rprofile`.
#' If the font is not found, the main font is TeX Gyre Heros,
#' a Helvetica clone that ships with the package
#' and is loaded by file name from its installation directory,
#' and a message explains how to make the font available.
#' The message is shown at the start and at the end of the render,
#' and again in the same R session only if its advice changes.
#' Any `mainfontoptions` set in the document are appended
#' to the options of the font.
#'
#' A document can use another font by setting `mainfont` in its YAML header,
#' a user by setting the option `zueridown.mainfont`, e.g. in `.Rprofile`.
#' The font can be the name of an installed font or a font file.
#' If it is not found, Helvetica Neue LT Pro or TeX Gyre Heros
#' is used instead, with a message.
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
