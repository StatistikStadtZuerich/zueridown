#' Create Footer
#'
#' Creates a footer for all pages.
#' Odd pages includes the page number on the right, even pages on the left.
#' When the document has a footer text this function includes it on the left
#' for odd pages, and on the right for even pages.
#'
#' @param footer_text Character. Vector that contains the footer text.
#'
#' @examples
#'
#' # For documents without footer text use:
#' cd_footer()
#' # For documents with footer text use:
#' cd_footer("footer text")
#' @export
cd_footer <- function(foot_text = default("")) {
  indiedown_path <- indiedown_path_tex()

  indiedown_glue(
    read_tex("footer.tex")
  )
}
