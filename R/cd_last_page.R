#' Last page LaTeX code
#'
#' Generates 'asis' LaTeX code to create the last page.
#' The user can choose an arrow or a QR code to include next
#' to the text and link page.
#'
#' @param text Character with the text to include above the link. Default "Mehr
#' Zahlen und Fakten  finden Sie unter".
#' @param link_label Character with the link to show in the last page
#' instead of a long link. Default "stadt-zuerich.ch".
#' @param link_full Character with the complete link to redirect clicking
#' on the document. The text does not need "https://www." at the begining",
#' the function adds this at the beggining. Default "stadt-zuerich.ch/statistik".
#' @param entity Default "Stadt Zürich".
#' @param department Default "department".
#' @param address Default "address".
#' @param tel Default "tel"
#' @param color_palette Color palette of the last page. Default
#' "palette1". You can see all palettes in \code{\link{cd_color_palette}}
#' @param arrow_qr Character to select if an arrow (arrow_qr = "arrow"),
#'  or a QR image (arrow_qr = "qr") is shown in the last page. When "qr" is
#'  selected a sample of a QR image is presented. To change this image, use the
#'  param "arrow_qr_path". Default "arrow".
#' @param arrow_qr_path path to the image of an arrow or QR code
#'  for the last page.
#'
#' @seealso \code{\link{cd_color_palette}}
#'
#' @export
#'
cd_last_page <- function(
  text = "Mehr Zahlen und Fakten  finden Sie unter",
  link_label = "stadt-zuerich.ch",
  link_full = "stadt-zuerich.ch/statistik",
  entity = "Stadt Zürich",
  department = "[department]",
  address = "[address]",
  tel = "[tel]",
  color_palette = cd_color_palette("palette1"),
  arrow_qr = default("arrow"),
  arrow_qr_path = default(
    NULL,
    system.file(
      package = "zueridown",
      "indiedown",
      "res",
      "Beispiel-QR-Code.png"
    )
  )
) {
  # variables used in .tex
  link_full <- paste0("https://www.", link_full)

  tel_nr <- paste("T:", tel, sep = " ")

  if (arrow_qr == "qr") {
    arrow_qr_path <- arrow_qr_path
    space_img <- "14.71mm"
  }
  if (arrow_qr == "arrow") {
    arrow_qr_path <- system.file(
      package = "zueridown",
      "indiedown",
      "res",
      "arrow.png"
    )
    space_img <- "21.71mm"
  }

  arrow_qr_path <- sanitize_tex(normalizePath(arrow_qr_path, mustWork = TRUE))
  indiedown_path <- indiedown_path_tex()

  last_page_background_color <- color_palette$last_page_background_color
  last_page_text_color <- color_palette$last_page_text_color
  last_page_link_color <- color_palette$last_page_link_color

  indiedown_glue(
    read_tex("last_page.tex")
  )
}
