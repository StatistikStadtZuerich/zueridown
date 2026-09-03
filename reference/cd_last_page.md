# Last page LaTeX code

Generates 'asis' LaTeX code to create the last page. The user can choose
an arrow or a QR code to include next to the text and link page.

## Usage

``` r
cd_last_page(
  text = "Mehr Zahlen und Fakten  finden Sie unter",
  link_label = "stadt-zuerich.ch",
  link_full = "stadt-zuerich.ch/statistik",
  entity = "Stadt Zürich",
  department = "[department]",
  address = "[address]",
  tel = "[tel]",
  color_palette = cd_color_palette("palette1"),
  arrow_qr = default("arrow"),
  arrow_qr_path = default(NULL, system.file(package = "zueridown", "indiedown", "res",
    "Beispiel-QR-Code.png"))
)
```

## Arguments

- text:

  Character with the text to include above the link. Default "Mehr
  Zahlen und Fakten finden Sie unter".

- link_label:

  Character with the link to show in the last page instead of a long
  link. Default "stadt-zuerich.ch".

- link_full:

  Character with the complete link to redirect clicking on the document.
  The text does not need "https://www." at the begining", the function
  adds this at the beggining. Default "stadt-zuerich.ch/statistik".

- entity:

  Default "Stadt Zürich".

- department:

  Default "department".

- address:

  Default "address".

- tel:

  Default "tel"

- color_palette:

  Color palette of the last page. Default "palette1". You can see all
  palettes in
  [`cd_color_palette`](https://statistikstadtzuerich.github.io/zueridown/reference/cd_color_palette.md)

- arrow_qr:

  Character to select if an arrow (arrow_qr = "arrow"), or a QR image
  (arrow_qr = "qr") is shown in the last page. When "qr" is selected a
  sample of a QR image is presented. To change this image, use the param
  "arrow_qr_path". Default "arrow".

- arrow_qr_path:

  path to the image of an arrow or QR code for the last page.

## See also

[`cd_color_palette`](https://statistikstadtzuerich.github.io/zueridown/reference/cd_color_palette.md)
