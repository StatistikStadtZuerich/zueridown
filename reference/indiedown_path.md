# Path helpers

`indiedown_path()` creates a path to this package's indiedown assets,
located at `inst/indiedown`.

`indiedown_path_tex()` creates a path that is usable in LaTeX, with all
special characters escaped.

## Usage

``` r
indiedown_path(...)

indiedown_path_tex(...)
```

## Arguments

- ...:

  Path components, passed on to
  [`system.file()`](https://rdrr.io/r/base/system.file.html).

## Value

Character string, path to this package's indiedown assets

## Examples

``` r
indiedown_path()
#> [1] "/home/runner/.cache/R/renv/library/zueridown-0b943ced/linux-ubuntu-resolute/R-4.6/x86_64-pc-linux-gnu/zueridown/indiedown"
```
