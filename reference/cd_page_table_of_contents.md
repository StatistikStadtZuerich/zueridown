# Title page LaTeX code

Generates 'asis' LaTeX code to create a table of content.

## Usage

``` r
cd_page_table_of_contents(
  color_palette = cd_color_palette("palette1"),
  toc_depth = 2
)
```

## Arguments

- color_palette:

  Character. Set the color palette for the background in the table of
  content. Default is "palette1". There are 14 possible color palettes.
  See more in ?cd_color_palette() function.

- toc_depth:

  Numeric. Specify the depth of headers in the table of content. Default
  is 2; meaning that all level 1 and 2 headers will be included in the
  table of content.
