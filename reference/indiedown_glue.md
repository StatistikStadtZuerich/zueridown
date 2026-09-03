# Glue LaTeX Code for Use in RMarkdown

Use the function to wrap literal LaTeX code in R. Use a raw string input
(\`r"()"\`) to automatically escape quotes and backslashes, as they are
common in LaTeX. Expressions enclosed by \`\<\<\` and \`\>\>\` will be
evaluated as R code.

## Usage

``` r
indiedown_glue(x, .open = "<<", .close = ">>")
```

## Arguments

- x:

  Character, often as a raw string (\`r"()"\`)

- .open, .close:

  The opening and closing delimiter.

## Details

\`indiedown_glue()\` uses a different default than the underlying
\`glue::glue()\` (\`\<\<\` and \`\>\>\`), because braces are so common
in LaTeX. Doubling the full delimiter (\`\<\<\<\<\` and \`\>\>\>\>\`)
escapes it.
