#' Create Footer
#'
#' Creates a footer for all pages.
#' Odd pages on the left, even on the right.
#' Page number is always in the center.
#'
#' @param footer_text Character. Vector that contains the footer text in different languages.
#'
#' @export
cd_footer <- function(foot_text = default("")) {
  indiedown_path <- indiedown_path_tex()

  indiedown_glue(
    read_tex("footer.tex")
  )
}
