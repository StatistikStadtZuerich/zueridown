# R Markdown output format backed by indiedown assets

Wraps
[`rmarkdown::pdf_document()`](https://pkgs.rstudio.com/rmarkdown/reference/pdf_document.html)
and injects the asset package's `preamble.tex` and pre-processor.
Downstream packages such as `zueridown` call this from their own output
format (see
[`zueridown()`](https://statistikstadtzuerich.github.io/zueridown/reference/zueridown.md)).

## Usage

``` r
indiedown_pdf_document_with_asset(includes = NULL, ...)
```

## Arguments

- includes:

  Named list as produced by
  [`rmarkdown::includes()`](https://pkgs.rstudio.com/rmarkdown/reference/includes.html).
  The asset `preamble.tex` is added as `in_header` unless one is already
  set.

- ...:

  Passed on to
  [`rmarkdown::pdf_document()`](https://pkgs.rstudio.com/rmarkdown/reference/pdf_document.html).

## Value

An R Markdown output format object.

## Details

The function is defined in `R/import-standalone-indiedown.R`, which does
not export it.
