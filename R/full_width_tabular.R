#' Convert a kable table to a full-width `tabularx`
#'
#' Rewrites the LaTeX produced by `kableExtra` so that a table created with
#' `full_width = TRUE` uses the `tabularx` environment instead of `tabu`. The
#' `tabu` package has known issues with colours and other features; `tabularx`
#' avoids them. See the package README for a usage example.
#'
#' @param x Character. The LaTeX code of a `kableExtra` table (typically the
#'   result of a `kable()` / `kable_styling()` pipeline).
#'
#' @return Called for its side effect: prints the rewritten LaTeX via [cat()]
#'   so it can be used in an `asis` chunk.
#'
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
