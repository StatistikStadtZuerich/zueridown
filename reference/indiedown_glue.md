# Glue LaTeX Code for Use in R Markdown

Use the function to wrap literal LaTeX code in R. Use a raw string input
(`r"()"`) to automatically escape quotes and backslashes, as they are
common in LaTeX. Expressions enclosed by `<<` and `>>` will be evaluated
as R code.

## Usage

``` r
indiedown_glue(x, .open = "<<", .close = ">>")
```

## Arguments

- x:

  Character, often as a raw string (`r"()"`)

- .open, .close:

  The opening and closing delimiter.

## Value

Object of class `"knit_asis"` (so that knitr will treat it as is).
Usually LaTeX code.

## Details

`indiedown_glue()` uses a different default than the underlying
[`glue::glue()`](https://glue.tidyverse.org/reference/glue.html) (`<<`
and `>>`), because braces are so common in LaTeX. Doubling the full
delimiter (`<<<<` and `>>>>`) escapes it.

## Examples

``` r
x <- "something"
indiedown_glue(r"(\LaTeX\ code with <<x>> substituted )")
#> [1] "\\LaTeX\\ code with something substituted "
#> attr(,"class")
#> [1] "knit_asis"
#> attr(,"knit_cacheable")
#> [1] NA
```
