# Create Footer

Creates a footer for all pages. Odd pages includes the page number on
the right, even pages on the left. When the document has a footer text
this function includes it on the left for odd pages, and on the right
for even pages.

## Usage

``` r
cd_footer(foot_text = default(""))
```

## Arguments

- foot_text:

  Character. Vector that contains the footer text.

## Examples

``` r

# For documents without footer text use:
cd_footer()
#> [1] "\\patchcmd{\\chapter}{\\thispagestyle{plain}}{\\thispagestyle{fancy}}{}{}\n\\pagestyle{fancy}\n\\fancyhf{}\n\\fancyfoot[RE,LO]{\\small }\n\\fancyfoot[LE,RO]{\\small \\thepage}"
#> attr(,"class")
#> [1] "knit_asis"
#> attr(,"knit_cacheable")
#> [1] NA
# For documents with footer text use:
cd_footer("footer text")
#> [1] "\\patchcmd{\\chapter}{\\thispagestyle{plain}}{\\thispagestyle{fancy}}{}{}\n\\pagestyle{fancy}\n\\fancyhf{}\n\\fancyfoot[RE,LO]{\\small footer text}\n\\fancyfoot[LE,RO]{\\small \\thepage}"
#> attr(,"class")
#> [1] "knit_asis"
#> attr(,"knit_cacheable")
#> [1] NA
```
