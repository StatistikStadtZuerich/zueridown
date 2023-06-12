#' Title page LaTeX code
#'
#' Generates 'asis' LaTeX code to create a table of content.
#'
#' @param color_palette Character. Set the color palette for the background in
#' the table of content. Default is "palette5".
#' There are 5 possible color palettes. See more in
#' ?cd_color_palette() function.
#'
#' @export
#'
cd_page_table_of_contents <- function(
  color_palette = cd_color_palette("palette5")
) {
  indiedown_path <- indiedown_path_tex()

  one_page_background_color <- color_palette$one_page_background_color
  text_color <- color_palette$text_color

  indiedown_glue(
    read_tex("table_of_contents.tex")
  )
}
