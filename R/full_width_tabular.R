#' @export
full_width_tabular <- function(x) {
  x <- gsub("{tabu}", "{tabularx}", x, fixed = TRUE)
  x <- gsub(" to \\linewidth ", "{\\linewidth}", x, fixed = TRUE)
  x <- gsub("raggedleft", "raggedleft\\arraybackslash", x, fixed = TRUE)
  x <- gsub("raggedright", "raggedright\\arraybackslash", x, fixed = TRUE)

  # FIXME: centering
  x <- gsub("centering", "centering\\arraybackslash", x, fixed = TRUE)

  cat(x[1])
}
