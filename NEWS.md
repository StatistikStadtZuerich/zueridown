# zueridown (development version)

* The main font is now the licensed Helvetica Neue LT Pro, 65 Medium with 85 Heavy as bold, if all of these faces are installed.
  Otherwise the bundled TeX Gyre Heros is used, and a message names the fallback and explains how to install fonts.
  The message appears at the start of the render and again at its end, once the PDF is written.
  A `mainfont` in the document or the `zueridown.mainfont` option still takes precedence.

* The code shared with other indiedown template packages
  now comes from indiedown as the standalone file `R/import-standalone-indiedown.R`.
  Update it with `usethis::use_standalone("cynkra/indiedown", "indiedown")`.

* A skipped visual test no longer deletes the stored snapshots.
  The toolchain record lists the bundled font files with checksums.
  A GitHub Actions workflow runs R CMD check with the snapshot tests and fails if any test is skipped.

* `twocolumn: true` no longer breaks `classoption`.
  Every class option from the document is now kept next to `twocolumn`,
  where `classoption: landscape` used to reach LaTeX as the unknown option `landscapetwocolumn`.

* Documents with `twocolumn: true` no longer warn "Package multicol Warning: May not work with the twocolumn option".
  `multicols` is still available in two-column documents.

* The documentation is generated with roxygen2 8, which drops `RoxygenNote` from `DESCRIPTION`.
  The help pages are unchanged.

* The help pages use Markdown, so backticks and links render properly.

* New visual snapshot tests render sample documents to PDF and compare each page byte for byte with stored images.
  The system fonts are hidden during the tests, and the toolchain is recorded next to the snapshots.

* TeX Gyre Heros, the fallback main font, now ships with the package and is loaded by file name.
  Rendering no longer fails with "The font "TeX Gyre Heros" cannot be found" on a fresh TinyTeX installation.
  The font keeps its own license, the GUST Font License, see `inst/COPYRIGHTS`.

# zueridown 1.0.0

* no functional changes
* run checks in pipeline
* create pkgdown site and make pkgdown ready for deployment on CMP

# zueridown 0.0.3.1

* fix missing dependencies
* fix logo

# zueridown 0.0.3

* improve documentation

before0.0.3: development versions
