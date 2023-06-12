#' Color Palettes
#'
#' There are five color palettes defined.
#'
#' The specification of the colors is:
#' \figure{palettes.png}
#'
#'
#' @export
cd_color_palette <- function(name = "palette5") {
  color_palette_palette1 <-
    list(
      banner = "293380",
      title_page_background_color = "DBEACB",
      title_page_color = "293380",
      one_page_background_color = "293380",
      text_color = "FFFFFF",
      text_color_blue = "293380",
      box_color = "0098C6",
      last_page_background_color = "293380",
      last_page_text_color = "97B4DF",
      last_page_link_color = "DBEACB"
    )

  color_palette_palette2 <-
    list(
      banner = "293380",
      title_page_background_color = "C5E6FA",
      title_page_color = "BF860F",
      one_page_background_color = "293380",
      text_color = "FFFFFF",
      text_color_blue = "293380",
      box_color = "BF860F",
      last_page_background_color = "293380",
      last_page_text_color = "97B4DF",
      last_page_link_color = "DBEACB"
    )

  color_palette_palette3 <-
    list(
      banner = "F9F08C",
      title_page_background_color = "293380",
      title_page_color = "F6A95F",
      one_page_background_color = "293380",
      text_color = "FFFFFF",
      text_color_blue = "293380",
      box_color = "F08785",
      last_page_background_color = "293380",
      last_page_text_color = "97B4DF",
      last_page_link_color = "DBEACB"
    )

  color_palette_palette4 <-
    list(
      banner = "70BD89",
      title_page_background_color = "293380",
      title_page_color = "C1AED5",
      one_page_background_color = "293380",
      text_color = "FFFFFF",
      text_color_blue = "293380",
      box_color = "5DABDF",
      last_page_background_color = "293380",
      last_page_text_color = "97B4DF",
      last_page_link_color = "DBEACB"
    )

  color_palette_palette5 <-
    list(
      banner = "293380",
      title_page_background_color = "F2F6F9",
      title_page_color = "293380",
      one_page_background_color = "293380",
      text_color = "FFFFFF",
      text_color_blue = "293380",
      box_color = "BCE3F4",
      last_page_background_color = "293380",
      last_page_text_color = "97B4DF",
      last_page_link_color = "DBEACB"
    )

  if (name == "palette1") {
    color_palette_palette1
  } else if (name == "palette2") {
    color_palette_palette2
  } else if (name == "palette3") {
    color_palette_palette3
  } else if (name == "palette4") {
    color_palette_palette4
  } else if (name == "palette5") {
    color_palette_palette5
  } else {
    stop("palette not defined")
  }
}
