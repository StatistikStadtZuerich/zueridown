# zueridown (development version)

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

* The main font, TeX Gyre Heros, now ships with the package and is loaded by file name.
  Rendering no longer fails with "The font "TeX Gyre Heros" cannot be found" on a fresh TinyTeX installation,
  and the output no longer depends on the fonts installed on the system.
  A `mainfont` set in the document takes precedence.
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
