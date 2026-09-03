# R Markdown output format backed by indiedown assets

Wraps \[rmarkdown::pdf_document()\] and injects the asset package's
\`preamble.tex\` and pre-processor. Downstream packages such as
\`zueridown\` call this from their own output format (see
\[zueridown()\]).

## Usage

``` r
indiedown_pdf_document_with_asset(includes = NULL, ...)
```

## Arguments

- includes:

  Named list as produced by \[rmarkdown::includes()\]. The asset
  \`preamble.tex\` is added as \`in_header\` unless one is already set.

- ...:

  Passed on to \[rmarkdown::pdf_document()\].

## Value

An R Markdown output format object.
