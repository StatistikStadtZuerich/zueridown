# Format a date for the title page

Formats a date according to the document language: a German long date
(e.g. \`1. Januar 2024\`) for German, otherwise an English long date.

## Usage

``` r
cd_format_date(date, lang = default(rmarkdown::metadata$lang, "de_CH"))
```

## Arguments

- date:

  A \`Date\` (or object coercible by \[format()\]).

- lang:

  Language code. Defaults to the document's \`lang\` metadata field,
  falling back to \`"de_CH"\`. German is used for \`"german"\`,
  \`"de-DE"\` and \`"de-CH"\`; any other value yields the English
  format.

## Value

A formatted date string.
