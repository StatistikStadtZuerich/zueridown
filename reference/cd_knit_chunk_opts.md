# Rmarkdown arguments

Configuration of arguments to set up chunks. You can check arguments and
options in the documentation of the knitr package at
<https://yihui.org/knitr/options/#chunk-options>

## Usage

``` r
cd_knit_chunk_opts(
  metadata = rmarkdown::metadata,
  fig.width = NULL,
  fig.height = NULL,
  fig.pos = "h",
  cache = FALSE,
  message = FALSE,
  echo = FALSE,
  tidy = FALSE
)
```

## Arguments

- metadata:

  Pass Rmarkdown arguments from yml header for instance title,
  twocolumn, or lang.

- fig.width, fig.height:

  Numeric. Default figure width/height in inches. When \`NULL\` (the
  default), sensible values are chosen from the \`twocolumn\` and
  \`wide\` metadata fields.

- fig.pos:

  Character. LaTeX figure placement specifier. Default \`"h"\`.

- cache:

  Logical. Knitr chunk caching. Default \`FALSE\`.

- message:

  Logical. Show messages. Default \`FALSE\`.

- echo:

  Logical. Echo source code. Default \`FALSE\`.

- tidy:

  Logical. Reformat code. Default \`FALSE\`.
