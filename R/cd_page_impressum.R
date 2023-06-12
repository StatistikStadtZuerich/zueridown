#' Title page LaTeX code
#'
#' Generates 'asis' LaTeX code to include the information of impressum page
#'
#' @param subtitle Character. Document subtitle. Default subtitle parameter in yml.
#' Use this parameter to specify a subtitle
#' different from the subtitle in the yml header of the document.
#' @param city Character. Default "Stadt Zürich".
#' @param department Character. Default "[department]".
#' @param address Character. Default "[address]"
#' @param tel Character. Default "[tel]"
#' @param email Character. Default "[email]"
#' @param web Character. Default "[web]"
#' @param date Character. Default "[date]"
#' @param authors Character. Default "[address]"
#' @param photo TRUE or FALSE. Default TRUE. When cd_page_title_photo is used,
#' this parameter should be TRUE.
#' @param credit Character. Default
#' @param space Character. Space betwwen Zeichenerklärung and impressum.
#' Default "0cm". When the "Zeichenerklärung" above is not necessary, this
#' parameter should be set to 15cm (space = "15cm").
#
#' @export
#'
cd_page_impressum <- function(
  subtitle = default(rmarkdown::metadata$subtitle),
  city = "Stadt Zürich",
  department = "[department]",
  address = "[address]",
  tel = "[tel]",
  email = "[email]",
  web = "[web]",
  date = "[date]",
  authors = "[authors]",
  photo = TRUE,
  credit = "[credit]",
  space = default("0cm")
) {
  indiedown_path <- indiedown_path_tex()

  link_full <- paste0("https://www.", web)

  if (photo == TRUE) {
    image <- "Bild"
    credit <- credit
    space_credit <- "0.5cm"
  } else {
    image <- ""
    credit <- ""
    space_credit <- "-3.5cm"
  }

  indiedown_glue(read_tex("page_impressum.tex"))
}
