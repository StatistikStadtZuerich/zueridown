# zueridown PDF output format

R Markdown output format for the city of Zurich corporate design. A thin
wrapper around \[indiedown_pdf_document_with_asset()\] that fixes the
syntax highlighting style and the LaTeX engine (\`xelatex\`, required
for the bundled fonts).

## Usage

``` r
zueridown(...)
```

## Arguments

- ...:

  Passed on to \[indiedown_pdf_document_with_asset()\] and, in turn, to
  \[rmarkdown::pdf_document()\].

## Value

An R Markdown output format object.
