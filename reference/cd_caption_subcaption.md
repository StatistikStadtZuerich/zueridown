# Plot/table title and subtitle

Creates a title and a subtitle above the plot /table. Special symbols
must be preceded by a \\ (ex. \\&)

## Usage

``` r
cd_caption_subcaption(
  caption = default(""),
  subcaption = default(""),
  label = default("")
)
```

## Arguments

- caption:

  Character. Written in bold

- subcaption:

  Character. If you want to have it on more lines, insert the latex
  command 'newline' in the code.

- label:

  Character. Optional LaTeX label for cross-referencing the figure or
  table (for example \`"fig:figura1"\`).
