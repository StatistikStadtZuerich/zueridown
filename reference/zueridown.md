# zueridown PDF output format

R Markdown output format for the city of Zurich corporate design. A thin
wrapper around
[`indiedown_pdf_document_with_asset()`](https://statistikstadtzuerich.github.io/zueridown/reference/indiedown_pdf_document_with_asset.md)
that fixes the syntax highlighting style and the LaTeX engine
(`xelatex`, required for the bundled fonts).

## Usage

``` r
zueridown(...)
```

## Arguments

- ...:

  Passed on to
  [`indiedown_pdf_document_with_asset()`](https://statistikstadtzuerich.github.io/zueridown/reference/indiedown_pdf_document_with_asset.md)
  and, in turn, to
  [`rmarkdown::pdf_document()`](https://pkgs.rstudio.com/rmarkdown/reference/pdf_document.html).

## Value

An R Markdown output format object.

## Details

The main font is Helvetica Neue LT Pro, the font of the corporate
design, if it is installed: 65 Medium as regular and 85 Heavy as bold.
The font is licensed and does not ship with the package. It is loaded
from its font files, which are found if the font is installed for the
current user or for all users. Users who cannot install fonts can copy
the font files to a folder and set the option `zueridown.font_path` to
that folder, e.g. in `.Rprofile`. If the font is not found, the main
font is TeX Gyre Heros, a Helvetica clone that ships with the package
and is loaded by file name from its installation directory, and a
message explains how to make the font available. The message is shown at
the start and at the end of the render, and again in the same R session
only if its advice changes. Any `mainfontoptions` set in the document
are appended to the options of the font.

A document can use another font by setting `mainfont` in its YAML
header, a user by setting the option `zueridown.mainfont`, e.g. in
`.Rprofile`. The font can be the name of an installed font or a font
file. If it is not found, Helvetica Neue LT Pro or TeX Gyre Heros is
used instead, with a message.
