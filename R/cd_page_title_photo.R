#' Title page LaTeX code
#'
#' Generates 'asis' LaTeX code to create a title page with a photo in the front
#' page.
#'
#' @param title Character. Document title. Default title parameter in yml.
#' Use this parameter to specify a title different from the title in the yml
#' header of the document.
#' @param subtitle Character. Document subtitle. Default subtitle parameter in yml.
#' Use this parameter to specify a subtitle
#' different from the subtitle in the yml header of the document.
#' @param date Character. Document creation date.
#' @param color_palette Character. Set the color palette for the document.
#' Default is "palette5". There are 5 possible color palettes. See more in
#' ?cd_color_palette() function.
#' @param subtitle_below Character. Default is empty blank. Set the subtitle for
#' the cover page.
#' @param title_image_path Character. The complete path of the picture for the
#' cover page. Default is the picture included in the package.
#' @param title_size Character. Fix the letter size for the title in the cover
#' page. Default is "40pt".
#' @param subtitle_size Character. Fix the letter size for the subtitle in the cover
#' page. Default is "25pt".
#' @param subtitle_below_size Character. The complete path of the picture. Default is
#' the picture included in the package.
#' @param logo_path Character. Character. The complete path of the logo for the
#' cover page. Default is the logo included in the package.
#'
#' @export
#'
cd_page_title_photo <- function(
  title = default(rmarkdown::metadata$title, "Title"),
  subtitle = default(rmarkdown::metadata$subtitle, "Subtitle"),
  date = default(rmarkdown::metadata$date, cd_format_date(Sys.Date())),
  color_palette = default(cd_color_palette("palette1")),
  subtitle_below = "",
  title_image_path = default(
    NULL,
    system.file(
      package = "zueridown",
      "example",
      "Jakob.jpg"
    )
  ),
  title_size = "40pt",
  subtitle_size = "25pt",
  subtitle_below_size = "20pt",
  logo_path = default(
    NULL,
    system.file(
      package = "zueridown",
      "indiedown",
      "res",
      "logo_stzh_ssz_cmyk_blau_print_a3_a4_a5.eps"
    )
  )
) {
  # variables used in .tex
  title_image_path <- sanitize_tex(normalizePath(
    title_image_path,
    mustWork = TRUE
  ))
  logo_path <- sanitize_tex(normalizePath(logo_path, mustWork = TRUE))
  indiedown_path <- indiedown_path_tex()

  title_page_background_color <- color_palette$title_page_background_color
  title_page_color <- color_palette$title_page_color
  banner <- color_palette$banner
  text_color_blue <- color_palette$text_color_blue

  indiedown_glue(
    read_tex("page_title_photo.tex")
  )
}
