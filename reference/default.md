# Default value for \`NULL\`

Returns \`x\`, or \`default\` when \`x\` is \`NULL\`. Used throughout
the \`cd\_\*\` helpers to fall back to a sensible default when a YAML
metadata field is absent.

## Usage

``` r
default(x, default = "")
```

## Arguments

- x:

  Value to test for \`NULL\`.

- default:

  Value to return when \`x\` is \`NULL\`. Defaults to \`""\`.

## Value

\`x\` if not \`NULL\`, otherwise \`default\`.
