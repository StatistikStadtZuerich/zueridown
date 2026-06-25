#' Format a date for the title page
#'
#' Formats a date according to the document language: a German long date
#' (e.g. `1. Januar 2024`) for German, otherwise an English long date.
#'
#' @param date A `Date` (or object coercible by [format()]).
#' @param lang Language code. Defaults to the document's `lang` metadata field,
#'   falling back to `"de_CH"`. German is used for `"german"`, `"de-DE"` and
#'   `"de-CH"`; any other value yields the English format.
#'
#' @return A formatted date string.
#'
#' @export
cd_format_date <- function(
  date,
  lang = default(rmarkdown::metadata$lang, "de_CH")
) {
  if (lang %in% c("german", "de-DE", "de-CH")) {
    withr::with_locale(c("LC_TIME" = "de_CH"), format(date, "%e. %B %Y"))
  } else {
    withr::with_locale(c("LC_TIME" = "en_US"), format(date, "%B %e, %Y"))
  }
}
