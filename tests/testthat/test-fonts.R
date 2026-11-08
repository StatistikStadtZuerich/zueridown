# The licensed font is not available on CI, so the system font lookup is mocked,
# and copies of the bundled TeX Gyre Heros stand in for its font files.

# Copies `files` from the bundled fonts to `dir`, renamed to `names`
copy_fonts <- function(dir, files, names = files) {
  dir.create(dir, recursive = TRUE, showWarnings = FALSE)
  stopifnot(file.copy(
    file.path(indiedown_path("fonts"), files),
    file.path(dir, names)
  ))
  normalizePath(dir, "/")
}

# TeX Gyre Heros in the place of the files of Helvetica Neue LT Pro,
# with the italics as Medium and Heavy, to tell them from the fallback font
licensed_files <- c("texgyreheros-italic.otf", "texgyreheros-bolditalic.otf")
licensed_names <- c("HelveticaNeueLTPro-Md.otf", "HelveticaNeueLTPro-Hv.otf")

# The defaults of a format with a fallback font only
fallback <- list(mainfont = "fallback.otf")

licensed_options <- paste0(
  "mainfontoptions:Path=%s/,BoldFont=HelveticaNeueLTPro-Hv.otf,",
  "ItalicFont=HelveticaNeueLTPro-Md.otf,BoldItalicFont=HelveticaNeueLTPro-Md.otf"
)

test_that("the licensed font is used by name if fc-list lists it", {
  local_mocked_bindings(
    font_dirs = function(...) NULL,
    installed_font_names = function() {
      c(
        "Helvetica Neue LT Pro",
        "HelveticaNeueLTPro-Md",
        "HelveticaNeueLTPro-Hv"
      )
    }
  )

  expect_silent(args <- apply_default_yaml(list()))
  expect_true("mainfont:HelveticaNeueLTPro-Md" %in% args)
  expect_true(
    paste0(
      "mainfontoptions:BoldFont=HelveticaNeueLTPro-Hv,",
      "ItalicFont=HelveticaNeueLTPro-Md,BoldItalicFont=HelveticaNeueLTPro-Md"
    ) %in%
      args
  )
})

test_that("TeX Gyre Heros is used if the licensed font is missing", {
  local_mocked_bindings(
    font_dirs = function(...) NULL,
    # Medium without Heavy is not enough
    installed_font_names = function() "HelveticaNeueLTPro-Md",
    font_messages = new.env()
  )

  expect_message(
    args <- apply_default_yaml(list()),
    'Preferred font "HelveticaNeueLTPro-Md" was not found, using "texgyreheros-regular.otf" instead'
  )
  expect_true("mainfont:texgyreheros-regular.otf" %in% args)
  expect_match(args, "^mainfontoptions:Path=.*/fonts/,", all = FALSE)

  # once per session
  expect_silent(apply_default_yaml(list()))
})

test_that("a font installed for the current user on Windows is loaded from its files", {
  appdata <- withr::local_tempdir()
  withr::local_envvar(LOCALAPPDATA = appdata)
  windows_dirs <- font_dirs("Windows")
  # next to an unrelated font, and in another case
  dir <- copy_fonts(
    windows_dirs,
    c("texgyreheros-regular.otf", licensed_files),
    c("other.otf", "HelveticaNeueLTPro-Md.otf", "helveticaneueltpro-hv.OTF")
  )
  # TeX Live's fc-list on Windows does not see these fonts
  local_mocked_bindings(
    font_dirs = function(...) windows_dirs,
    installed_font_names = function() character()
  )

  expect_silent(args <- apply_default_yaml(list()))
  expect_true("mainfont:HelveticaNeueLTPro-Md.otf" %in% args)
  expect_true(
    paste0(
      "mainfontoptions:Path=",
      dir,
      "/,BoldFont=helveticaneueltpro-hv.OTF,",
      "ItalicFont=HelveticaNeueLTPro-Md.otf,BoldItalicFont=HelveticaNeueLTPro-Md.otf"
    ) %in%
      args
  )
})

test_that("only Windows has a folder of fonts that fc-list does not see", {
  withr::local_envvar(LOCALAPPDATA = "C:/Users/me/AppData/Local")
  expect_identical(
    font_dirs("Windows"),
    "C:/Users/me/AppData/Local/Microsoft/Windows/Fonts"
  )
  expect_null(font_dirs("Linux"))
  expect_null(font_dirs("Darwin"))

  # hidden from the snapshot tests
  withr::local_options(zueridown.system_fonts = FALSE)
  expect_null(font_dirs("Windows"))
})

test_that("the option zueridown.font_path names a folder with the font files", {
  local_mocked_bindings(
    font_dirs = function(...) NULL,
    installed_font_names = function() NULL,
    font_messages = new.env()
  )
  dir <- copy_fonts(withr::local_tempdir(), licensed_files, licensed_names)
  withr::local_options(zueridown.font_path = dir)

  expect_silent(args <- apply_default_yaml(list()))
  expect_true("mainfont:HelveticaNeueLTPro-Md.otf" %in% args)
  expect_true(sprintf(licensed_options, dir) %in% args)

  withr::local_options(zueridown.font_path = file.path(dir, "missing"))
  expect_message(
    args <- apply_default_yaml(list()),
    paste0(
      'using "texgyreheros-regular.otf" instead.\n',
      'To use it, check that the folder "',
      file.path(dir, "missing"),
      '" from the option `zueridown.font_path` holds its font files, ',
      'named like "HelveticaNeueLTPro-Md.otf" or ".ttf".'
    ),
    fixed = TRUE
  )
  expect_true("mainfont:texgyreheros-regular.otf" %in% args)
})

test_that("a named font file is not found if named with its folder", {
  local_mocked_bindings(
    font_dirs = function(...) NULL,
    installed_font_names = function() character(),
    font_messages = new.env()
  )
  # fontspec fails on a folder in the name, also if the file exists
  dir <- withr::local_tempdir()
  copy_fonts(file.path(dir, "fonts"), licensed_files[[1]], "Some-Regular.otf")
  withr::local_dir(dir)

  expect_message(
    expect_identical(
      resolve_fonts(list(mainfont = "fonts/Some-Regular.otf"), fallback),
      fallback
    ),
    paste0(
      'Font "fonts/Some-Regular.otf" from the `mainfont` field of the document ',
      'was not found, using "fallback.otf" instead.\n',
      "To use it, check the path, and give only the file name, ",
      "with its folder as `Path=` in `mainfontoptions`, ",
      "relative to the folder of the document.\n"
    ),
    fixed = TRUE
  )
  # also for another face
  named <- list(mainfont = "some.otf", mainfontoptions = "BoldFont=C:/b.otf")
  expect_message(
    expect_identical(resolve_fonts(named, fallback), fallback),
    'Font "some.otf"',
    fixed = TRUE
  )

  # the folder as `Path=`
  named <- list(mainfont = "Some-Regular.otf", mainfontoptions = "Path=fonts/")
  expect_silent(expect_identical(resolve_fonts(named, fallback), named))
})

test_that("the message on Windows asks to install for the current user", {
  hint <- font_install_hint("HelveticaNeueLTPro-Md", sysname = "Windows")
  expect_match(hint, "for the current user", fixed = TRUE)
  expect_match(hint, "Settings > Personalization > Fonts", fixed = TRUE)
  expect_match(hint, "options(zueridown.font_path", fixed = TRUE)
  expect_no_match(hint, "all users", fixed = TRUE)

  # a named font, which may be named other than its files
  hint <- font_install_hint("Some Sans", sysname = "Windows", named = TRUE)
  expect_match(hint, "for all users", fixed = TRUE)
  expect_no_match(hint, "current user", fixed = TRUE)
  expect_match(hint, "options(zueridown.font_path", fixed = TRUE)
})

test_that("a named font takes precedence if fc-list lists all its fonts", {
  local_mocked_bindings(
    font_dirs = function(...) NULL,
    installed_font_names = function() {
      c("DejaVu Sans", "Some Sans", "Some Sans Bold", "HelveticaNeueLTPro-Md")
    }
  )

  expect_silent(args <- apply_default_yaml(list(mainfont = "DejaVu Sans")))
  expect_true("mainfont:DejaVu Sans" %in% args)
  expect_false(any(grepl("^mainfontoptions:", args)))

  withr::local_options(zueridown.mainfont = "some sans")
  options <- c("BoldFont=* Bold", "Scale=0.9")
  expect_identical(
    resolve_fonts(list(mainfontoptions = options), fallback),
    list(mainfont = "some sans", mainfontoptions = options)
  )
})

test_that("a named font is loaded from its files", {
  local_mocked_bindings(
    font_dirs = function(...) NULL,
    installed_font_names = function() character()
  )
  dir <- copy_fonts(
    withr::local_tempdir(),
    licensed_files,
    c("Some-Regular.otf", "Some-Bold.otf")
  )
  withr::local_options(zueridown.font_path = dir)

  expect_silent(
    args <- apply_default_yaml(list(
      mainfont = "Some-Regular",
      mainfontoptions = c("BoldFont=Some-Bold", "Scale=0.9")
    ))
  )
  expect_true("mainfont:Some-Regular.otf" %in% args)
  expect_true(
    paste0(
      "mainfontoptions:Path=",
      dir,
      "/,BoldFont=Some-Bold.otf,Scale=0.9"
    ) %in%
      args
  )

  # from the option, in the folder of the fonts installed for the current user
  local_mocked_bindings(font_dirs = function(...) dir)
  withr::local_options(
    zueridown.font_path = NULL,
    zueridown.mainfont = "Some-Regular"
  )
  expect_identical(
    resolve_fonts(list(), fallback),
    list(
      mainfont = "Some-Regular.otf",
      mainfontoptions = paste0("Path=", dir, "/")
    )
  )
})

test_that("a missing named font falls back with a message", {
  local_mocked_bindings(
    font_dirs = function(...) NULL,
    installed_font_names = function() character(),
    font_messages = new.env()
  )

  messages <- capture_messages(
    args <- apply_default_yaml(list(
      mainfont = "Missing Sans",
      mainfontoptions = "Scale=0.9"
    ))
  )
  # one message, although the preferred font is missing too
  expect_length(messages, 1)
  expect_match(
    messages,
    paste0(
      'Font "Missing Sans" from the `mainfont` field of the document ',
      'was not found, using "texgyreheros-regular.otf" instead.\n',
      "To use it, copy its font files"
    ),
    fixed = TRUE
  )
  expect_true("mainfont:texgyreheros-regular.otf" %in% args)
  # without the options of the missing font
  expect_false(any(grepl("Scale=", args, fixed = TRUE)))

  # from the option, with the preferred font installed
  local_mocked_bindings(
    installed_font_names = function() {
      c("HelveticaNeueLTPro-Md", "HelveticaNeueLTPro-Hv")
    }
  )
  withr::local_options(zueridown.mainfont = "Missing Sans")
  expect_message(
    args <- apply_default_yaml(list()),
    paste0(
      'Font "Missing Sans" from the option `zueridown.mainfont` ',
      'was not found, using "HelveticaNeueLTPro-Md" instead.'
    ),
    fixed = TRUE
  )
  expect_true("mainfont:HelveticaNeueLTPro-Md" %in% args)
})

test_that("a named font is used as named if the lookup cannot tell", {
  local_mocked_bindings(
    font_dirs = function(...) NULL,
    installed_font_names = function() NULL
  )

  # without fc-list
  expect_silent(args <- apply_default_yaml(list(mainfont = "Some Sans")))
  expect_true("mainfont:Some Sans" %in% args)

  # a font file, which fc-list does not list
  local_mocked_bindings(installed_font_names = function() character())
  named <- list(
    mainfont = "some.otf",
    mainfontoptions = "BoldFont=some-bold.ttf"
  )
  expect_identical(resolve_fonts(named, fallback), named)

  # with `Path=`, also next to files of the same name in the option's folder
  dir <- copy_fonts(
    withr::local_tempdir(),
    licensed_files,
    c("Some-Regular.otf", "Some-Bold.otf")
  )
  withr::local_options(zueridown.font_path = dir)
  named <- list(
    mainfont = "Some-Regular",
    mainfontoptions = c("Path=fonts/", "Extension=.otf", "BoldFont=Some-Bold")
  )
  expect_identical(resolve_fonts(named, fallback), named)
  named$mainfontoptions[[1]] <- "Path = fonts/"
  expect_identical(resolve_fonts(named, fallback), named)

  # without a fallback font
  expect_identical(
    resolve_fonts(list(mainfont = "Other Sans"), list()),
    list(mainfont = "Other Sans")
  )
})

test_that("a font that fc-list lists is used by name", {
  skip_if_not(nzchar(Sys.which("fc-list")), "fc-list not available")
  # fontconfig sees only the fonts in `dir`, under other file names
  dir <- copy_fonts(withr::local_tempdir(), licensed_files, c("a.otf", "b.otf"))
  conf <- file.path(dir, "fonts.conf")
  writeLines(
    c(
      "<?xml version=\"1.0\"?>",
      "<!DOCTYPE fontconfig SYSTEM \"fonts.dtd\">",
      "<fontconfig>",
      paste0("  <dir>", dir, "</dir>"),
      paste0("  <cachedir>", file.path(dir, "cache"), "</cachedir>"),
      "</fontconfig>"
    ),
    conf
  )
  withr::local_envvar(FONTCONFIG_FILE = conf)
  local_mocked_bindings(font_dirs = function(...) NULL)

  preferred <- list(
    preferredmainfont = "TeXGyreHeros-Italic",
    preferredmainfontoptions = "BoldFont=TeXGyreHeros-BoldItalic"
  )
  expect_identical(
    resolve_fonts(list(), c(fallback, preferred)),
    list(
      mainfont = "TeXGyreHeros-Italic",
      mainfontoptions = "BoldFont=TeXGyreHeros-BoldItalic"
    )
  )

  # also a named font
  named <- list(mainfont = "TeX Gyre Heros", mainfontoptions = "Scale=0.9")
  expect_identical(resolve_fonts(named, fallback), named)
  local_mocked_bindings(font_messages = new.env())
  expect_message(
    expect_identical(
      resolve_fonts(list(mainfont = "TeXGyreHeros-Regular"), fallback),
      fallback
    ),
    'Font "TeXGyreHeros-Regular" from the `mainfont` field of the document was not found',
    fixed = TRUE
  )
})

test_that("the font files from the option or the user's fonts are embedded", {
  skip_on_cran()
  skip_if_not_installed("pdftools")
  skip_if_not(rmarkdown::pandoc_available(), "pandoc not available")
  skip_if_not(nzchar(Sys.which("xelatex")), "xelatex not available")

  dir <- withr::local_tempdir()
  withr::local_envvar(LOCALAPPDATA = file.path(dir, "AppData"))
  windows_dirs <- font_dirs("Windows")
  local_mocked_bindings(
    font_dirs = function(...) NULL,
    installed_font_names = function() character()
  )
  input <- file.path(dir, "fonts.Rmd")
  writeLines(
    c(
      "---",
      "title: Fonts",
      "lang: en-US",
      "output: zueridown::zueridown",
      "---",
      "",
      "Regular, **bold** and *italic* text."
    ),
    input
  )
  embedded_fonts <- function() {
    pdf <- rmarkdown::render(input, quiet = TRUE, envir = new.env())
    fonts <- pdftools::pdf_fonts(pdf)
    # without the subset prefix and the encoding
    sub("^[A-Z]{6}[+](.*?)(-Identity-H)?$", "\\1", fonts$name[fonts$embedded])
  }

  withr::with_options(
    list(
      zueridown.font_path = copy_fonts(
        file.path(dir, "fonts"),
        licensed_files,
        licensed_names
      )
    ),
    fonts <- embedded_fonts()
  )
  expect_true(
    all(c("TeXGyreHeros-Italic", "TeXGyreHeros-BoldItalic") %in% fonts)
  )
  expect_false("TeXGyreHeros-Regular" %in% fonts)

  copy_fonts(windows_dirs, licensed_files, licensed_names)
  local_mocked_bindings(font_dirs = function(...) windows_dirs)
  fonts <- embedded_fonts()
  expect_true(
    all(c("TeXGyreHeros-Italic", "TeXGyreHeros-BoldItalic") %in% fonts)
  )
  expect_false("TeXGyreHeros-Regular" %in% fonts)
})

test_that("the format repeats the font message after the output is written", {
  skip_if_not(rmarkdown::pandoc_available(), "pandoc not available")
  local_mocked_bindings(
    font_dirs = function(...) NULL,
    installed_font_names = function() NULL,
    font_messages = new.env()
  )
  input <- file.path(withr::local_tempdir(), "doc.Rmd")
  writeLines(c("---", "title: Doc", "---", "", "Text."), input)
  render <- function() {
    utils::capture.output(
      messages <- capture_messages(rmarkdown::render(
        input,
        zueridown(),
        # pandoc only, without LaTeX
        output_file = "doc.tex",
        envir = new.env()
      ))
    )
    messages
  }

  messages <- render()
  font <- grep("Preferred font", messages, fixed = TRUE)
  expect_length(font, 2)
  expect_identical(messages[[font[[1]]]], messages[[font[[2]]]])
  # the last message, after the "Output created" line
  expect_identical(font[[2]], length(messages))
  expect_match(messages[[font[[2]] - 1]], "Output created")

  # a render without the message does not repeat it
  messages <- render()
  expect_false(any(grepl("Preferred font", messages, fixed = TRUE)))

  # the same for a missing named font
  local_mocked_bindings(installed_font_names = function() character())
  writeLines(
    c("---", "title: Doc", "mainfont: Missing Sans", "---", "", "Text."),
    input
  )
  messages <- render()
  font <- grep('Font "Missing Sans"', messages, fixed = TRUE)
  expect_length(font, 2)
  expect_identical(font[[2]], length(messages))
  expect_match(messages[[font[[2]] - 1]], "Output created")
})

test_that("get_indiedown_option() reads the option of the package", {
  expect_identical(indiedown_option_name("font_path"), "zueridown.font_path")
  expect_null(get_indiedown_option("font_path"))
  expect_identical(get_indiedown_option("font_path", "default"), "default")

  withr::local_options(zueridown.font_path = "fonts", indiedown.font_path = "x")
  expect_identical(get_indiedown_option("font_path"), "fonts")
  expect_identical(get_indiedown_option("font_path", "default"), "fonts")
})
