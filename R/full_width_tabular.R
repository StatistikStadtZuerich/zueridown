#' @export
full_width_tabular <- function(x) {
  x <- str_replace_all(
    x,
    fixed("{tabu}"),
    "{tabularx}"
  )
  x <- str_replace_all(
    x,
    fixed(" to \\linewidth "),
    "{\\linewidth}"
  )
  x <- str_replace_all(
    x,
    fixed("raggedleft"),
    "raggedleft\\arraybackslash"
  )

  x <- str_replace_all(
    x,
    fixed("raggedright"),
    "raggedright\\arraybackslash"
  )

  # FIXME: centering
  x <- str_replace_all(
    x,
    fixed("centering"),
    "centering\\arraybackslash"
  )

  return(cat(x[1]))
}
