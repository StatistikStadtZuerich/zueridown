# Set Default Value

Set default value of an argument. If `x` is `NULL`, `default` is used.

## Usage

``` r
default(x, default = "")
```

## Arguments

- x:

  Character string, or `NULL`

- default:

  If `x` is `NULL`, `default` is used.

## Value

Character string

## Examples

``` r
default(NULL)
#> [1] ""
default(NULL, "my default")
#> [1] "my default"
default("a string", "my default")
#> [1] "a string"
```
