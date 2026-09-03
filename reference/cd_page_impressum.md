# Title page LaTeX code

Generates 'asis' LaTeX code to include the information of impressum page

## Usage

``` r
cd_page_impressum(
  subtitle = default(rmarkdown::metadata$subtitle),
  city = "Stadt Zürich",
  department = "[department]",
  address = "[address]",
  tel = "[tel]",
  email = "[email]",
  web = "[web]",
  date = "[date]",
  authors = "[authors]",
  photo = TRUE,
  credit = "[credit]",
  space = default("0cm")
)
```

## Arguments

- subtitle:

  Character. Document subtitle. Default subtitle parameter in yml. Use
  this parameter to specify a subtitle different from the subtitle in
  the yml header of the document.

- city:

  Character. Default "Stadt Zürich".

- department:

  Character. Default "\[department\]".

- address:

  Character. Default "\[address\]"

- tel:

  Character. Default "\[tel\]"

- email:

  Character. Default "\[email\]"

- web:

  Character. Default "\[web\]"

- date:

  Character. Default "\[date\]"

- authors:

  Character. Default "\[address\]"

- photo:

  TRUE or FALSE. Default TRUE. When cd_page_title_photo is used, this
  parameter should be TRUE.

- credit:

  Character. Default

- space:

  Character. Space betwwen Zeichenerklärung and impressum. Default
  "0cm". When the "Zeichenerklärung" above is not necessary, this
  parameter should be set to 15cm (space = "15cm").
