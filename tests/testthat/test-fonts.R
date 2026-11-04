# The licensed font is not available on CI, so the system font lookup is mocked,
# and copies of the bundled TeX Gyre Heros stand in for its font files.

# No installed fonts, as fc-list lists them on a system without fonts
no_fonts <- function(...) {
  list(path = character(), name = character(), family = character())
}

# systemfonts as if it were missing, or installed in an `old` version
local_systemfonts <- function(old = NULL, .env = parent.frame()) {
  local_mocked_bindings(
    is_installed = function(pkg, ..., version = NULL) {
      !is.null(old) && is.null(version)
    },
    .package = "rlang",
    .env = .env
  )
  if (!is.null(old)) {
    local_mocked_bindings(
      packageVersion = function(...) package_version(old),
      .package = "utils",
      .env = .env
    )
  }
}

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

licensed_options <- paste0(
  "mainfontoptions:Path=%s/,BoldFont=HelveticaNeueLTPro-Hv.otf,",
  "ItalicFont=HelveticaNeueLTPro-Md.otf,BoldItalicFont=HelveticaNeueLTPro-Md.otf"
)

test_that("the licensed font is used by name if only its name is installed", {
  local_mocked_bindings(
    font_dirs = function(...) list(),
    installed_fonts = no_fonts,
    installed_font_names = function(...) {
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
    font_dirs = function(...) list(),
    installed_fonts = no_fonts,
    # Medium without Heavy is not enough
    installed_font_names = function(...) "HelveticaNeueLTPro-Md",
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

test_that("a font installed for the current user on Windows is loaded by path", {
  skip_if_not_installed("systemfonts", "1.3.0")
  appdata <- withr::local_tempdir()
  # file names that differ from the PostScript names,
  # next to an unrelated font
  user_fonts <- copy_fonts(
    file.path(appdata, "Microsoft", "Windows", "Fonts"),
    c(
      "texgyreheros-italic.otf",
      "texgyreheros-regular.otf",
      "texgyreheros-bold.otf"
    ),
    c("other.otf", "heros-md.otf", "heros-hv.otf")
  )
  withr::local_envvar(LOCALAPPDATA = appdata, WINDIR = withr::local_tempdir())
  windows_dirs <- font_dirs("Windows")
  # TeX Live's fc-list on Windows does not see these fonts
  local_mocked_bindings(
    font_dirs = function(...) windows_dirs,
    installed_fonts = no_fonts
  )

  # declared by PostScript name, as Helvetica Neue LT Pro in default.yaml,
  # and found by it
  defaults <- list(
    mainfont = "fallback.otf",
    preferredmainfont = "TeXGyreHeros-Regular",
    preferredmainfontoptions = c(
      "BoldFont=TeXGyreHeros-Bold",
      "ItalicFont=TeXGyreHeros-Regular",
      "BoldItalicFont=TeXGyreHeros-Regular"
    )
  )
  expect_silent(fonts <- resolve_fonts(list(), defaults))
  expect_identical(
    fonts,
    list(
      mainfont = "heros-md.otf",
      mainfontoptions = c(
        paste0("Path=", user_fonts, "/"),
        "BoldFont=heros-hv.otf",
        "ItalicFont=heros-md.otf",
        "BoldItalicFont=heros-md.otf"
      )
    )
  )

  # also if named in the document,
  # with the italic of its family, but no heavier bold
  expect_identical(
    resolve_fonts(list(mainfont = "TeXGyreHeros-Bold"), defaults),
    list(
      mainfont = "heros-hv.otf",
      mainfontoptions = c(
        paste0("Path=", user_fonts, "/"),
        "ItalicFont=other.otf"
      )
    )
  )
})

test_that("the option zueridown.font_path names a folder with the font files", {
  local_mocked_bindings(
    font_dirs = function(...) list(),
    installed_fonts = no_fonts,
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
      '" from the option `zueridown.font_path` holds its font files.'
    ),
    fixed = TRUE
  )
  expect_true("mainfont:texgyreheros-regular.otf" %in% args)
})

test_that("the message on Windows asks to install for the current user", {
  hint <- font_install_hint("HelveticaNeueLTPro-Md", "Windows")
  expect_match(hint, "for the current user", fixed = TRUE)
  expect_match(hint, "Settings > Personalization > Fonts", fixed = TRUE)
  expect_no_match(hint, "all users", fixed = TRUE)
})

test_that("a font named in the document takes precedence", {
  local_mocked_bindings(
    installed_font_names = function(...) {
      c("DejaVu Sans", "HelveticaNeueLTPro-Md", "HelveticaNeueLTPro-Hv")
    }
  )

  args <- apply_default_yaml(list(mainfont = "DejaVu Sans"))
  expect_true("mainfont:DejaVu Sans" %in% args)
  expect_false(any(grepl("^mainfontoptions:", args)))
})

test_that("the font files from the option or the user's fonts are embedded", {
  skip_on_cran()
  skip_if_not_installed("pdftools")
  skip_if_not(rmarkdown::pandoc_available(), "pandoc not available")
  skip_if_not(nzchar(Sys.which("xelatex")), "xelatex not available")

  dir <- withr::local_tempdir()
  appdata <- file.path(dir, "AppData")
  withr::local_envvar(LOCALAPPDATA = appdata, WINDIR = "")
  windows_dirs <- font_dirs("Windows")
  local_mocked_bindings(
    font_dirs = function(...) list(),
    installed_fonts = no_fonts
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

  copy_fonts(
    file.path(appdata, "Microsoft", "Windows", "Fonts"),
    licensed_files,
    licensed_names
  )
  local_mocked_bindings(font_dirs = function(...) windows_dirs)
  fonts <- embedded_fonts()
  expect_true(
    all(c("TeXGyreHeros-Italic", "TeXGyreHeros-BoldItalic") %in% fonts)
  )
  expect_false("TeXGyreHeros-Regular" %in% fonts)
})

# The Linux font folders, with the home folder and XDG_DATA_HOME of the test,
# unset by default, so that fontconfig reads ~/.local/share/fonts
local_linux_dirs <- function(home = withr::local_tempdir(), xdg = NA) {
  withr::local_envvar(
    HOME = home,
    XDG_DATA_HOME = xdg,
    .local_envir = parent.frame()
  )
  linux_dirs <- font_dirs("Linux")
  local_mocked_bindings(
    font_dirs = function(...) linux_dirs,
    .env = parent.frame()
  )
  home
}

licensed_defaults <- list(
  mainfont = "fallback.otf",
  preferredmainfont = "HelveticaNeueLTPro-Md",
  preferredmainfontoptions = c(
    "BoldFont=HelveticaNeueLTPro-Hv",
    "ItalicFont=HelveticaNeueLTPro-Md",
    "BoldItalicFont=HelveticaNeueLTPro-Md"
  )
)

expect_loaded_from <- function(fonts, dir) {
  expect_identical(fonts$mainfont, "HelveticaNeueLTPro-Md.otf")
  expect_identical(fonts$mainfontoptions[[1]], paste0("Path=", dir, "/"))
}

test_that("a font named as a font file is found by its file name", {
  appdata <- withr::local_tempdir()
  withr::local_envvar(LOCALAPPDATA = appdata, WINDIR = withr::local_tempdir())
  windows_dirs <- font_dirs("Windows")
  local_mocked_bindings(
    font_dirs = function(...) list(),
    installed_fonts = no_fonts,
    font_messages = new.env()
  )
  dir <- copy_fonts(withr::local_tempdir(), licensed_files, licensed_names)
  faces <- c(
    "BoldFont=HelveticaNeueLTPro-Hv.otf",
    "ItalicFont=*",
    "BoldItalicFont=HelveticaNeueLTPro-Hv.otf"
  )
  loaded <- function(dir) {
    list(
      mainfont = "HelveticaNeueLTPro-Md.otf",
      mainfontoptions = c(
        paste0("Path=", dir, "/"),
        "BoldFont=HelveticaNeueLTPro-Hv.otf",
        "ItalicFont=HelveticaNeueLTPro-Md.otf",
        "BoldItalicFont=HelveticaNeueLTPro-Hv.otf"
      )
    )
  }

  # the preferred font, in the folder of the option
  defaults <- licensed_defaults
  defaults$preferredmainfont <- "HelveticaNeueLTPro-Md.otf"
  defaults$preferredmainfontoptions <- faces
  expect_silent(fonts <- resolve_fonts(list(), defaults, font_path = dir))
  expect_identical(fonts, loaded(dir))

  # a named font, in the folder of the option
  named <- list(mainfont = "HelveticaNeueLTPro-Md.otf", mainfontoptions = faces)
  expect_silent(
    fonts <- resolve_fonts(named, licensed_defaults, font_path = dir)
  )
  expect_identical(fonts, loaded(dir))

  # and among the fonts installed for the current user on Windows
  user <- copy_fonts(
    file.path(appdata, "Microsoft", "Windows", "Fonts"),
    licensed_files,
    licensed_names
  )
  local_mocked_bindings(font_dirs = function(...) windows_dirs)
  expect_identical(resolve_fonts(named, licensed_defaults), loaded(user))

  # but not with a folder
  named$mainfont <- file.path("fonts", "HelveticaNeueLTPro-Md.otf")
  fallback <- list(mainfont = "fallback.otf")
  expect_message(
    fonts <- resolve_fonts(named, fallback, font_path = dir),
    "check the path",
    fixed = TRUE
  )
  expect_identical(fonts, fallback)
})

test_that("the message about unidentified files keeps the extension of a file", {
  local_systemfonts()
  local_mocked_bindings(
    font_dirs = function(...) list(),
    installed_fonts = no_fonts,
    font_messages = new.env()
  )
  dir <- copy_fonts(withr::local_tempdir(), licensed_files, c("a.otf", "b.otf"))
  defaults <- licensed_defaults
  defaults$preferredmainfont <- "HelveticaNeueLTPro-Md.otf"
  expect_message(
    fonts <- resolve_fonts(list(), defaults, font_path = dir),
    'such as "HelveticaNeueLTPro-Md.otf",\n',
    fixed = TRUE
  )
  expect_identical(fonts, list(mainfont = "fallback.otf"))
})

test_that("without fc-list and systemfonts, the fallback font is used", {
  skip_on_os(c("windows", "mac"))
  withr::local_envvar(PATH = R.home("bin"))
  local_mocked_bindings(
    font_dirs = function(...) list(),
    font_messages = new.env()
  )
  local_systemfonts()

  expect_message(
    fonts <- resolve_fonts(list(), licensed_defaults),
    paste0(
      'Preferred font "HelveticaNeueLTPro-Md" was not found, ',
      'using "fallback.otf" instead.\n',
      "The systemfonts package could not be loaded, ",
      "which may be why the font lookup failed.\n",
      "To use it, install systemfonts 1.3.0 or later ",
      'with `install.packages("systemfonts")`,\n',
      "or copy its font files to ~/.local/share/fonts, and restart R,\n"
    ),
    fixed = TRUE
  )
  expect_identical(fonts, list(mainfont = "fallback.otf"))

  # a named font is left to LaTeX
  expect_silent(
    fonts <- resolve_fonts(list(mainfont = "Some Sans"), licensed_defaults)
  )
  expect_identical(fonts, list(mainfont = "Some Sans"))
})

test_that("an old systemfonts gives a warning and the fallback font", {
  local_systemfonts("1.2.3")
  local_mocked_bindings(
    font_dirs = function(...) list(),
    installed_fonts = no_fonts,
    font_messages = new.env()
  )
  # the files of the licensed font, but not by name,
  # and an unrelated font
  dir <- copy_fonts(
    withr::local_tempdir(),
    c("texgyreheros-regular.otf", licensed_files),
    c("other.otf", "md.otf", "hv.otf")
  )
  withr::local_options(zueridown.font_path = dir)

  expect_warning(
    expect_message(
      fonts <- resolve_fonts(list(), licensed_defaults),
      "The systemfonts package could not be loaded",
      fixed = TRUE
    ),
    paste0(
      "The font lookup needs systemfonts 1.3.0 or later, ",
      "but version 1.2.3 is installed.\n"
    ),
    fixed = TRUE
  )
  expect_identical(fonts, list(mainfont = "fallback.otf"))

  # once per session
  expect_silent(resolve_fonts(list(), licensed_defaults))
})

test_that("font files are recognised by PostScript name with systemfonts", {
  skip_if_not_installed("systemfonts", "1.3.0")
  local_mocked_bindings(
    font_dirs = function(...) list(),
    installed_fonts = no_fonts,
    font_messages = new.env()
  )
  dir <- copy_fonts(
    withr::local_tempdir(),
    c("texgyreheros-regular.otf", "texgyreheros-bold.otf", licensed_files),
    c("other.otf", "zz.otf", "md.otf", "hv.otf")
  )
  defaults <- list(
    mainfont = "fallback.otf",
    preferredmainfont = "TeXGyreHeros-Italic",
    preferredmainfontoptions = "BoldFont=TeXGyreHeros-BoldItalic"
  )
  expect_identical(
    resolve_fonts(list(), defaults, font_path = dir),
    list(
      mainfont = "md.otf",
      mainfontoptions = c(
        paste0("Path=", dir, "/"),
        "BoldFont=hv.otf",
        "ItalicFont=md.otf",
        "BoldItalicFont=hv.otf"
      )
    )
  )
  # also a named font
  expect_identical(
    resolve_fonts(
      list(mainfont = "TeXGyreHeros-Bold", mainfontoptions = "Scale=0.9"),
      defaults,
      font_path = dir
    ),
    list(
      mainfont = "zz.otf",
      mainfontoptions = c(
        paste0("Path=", dir, "/"),
        "Scale=0.9",
        "ItalicFont=hv.otf"
      )
    )
  )

  # without systemfonts, the message explains how to do without it
  local_systemfonts()
  expect_message(
    fonts <- resolve_fonts(list(), defaults, font_path = dir),
    paste0(
      'Preferred font "TeXGyreHeros-Italic" was not found, ',
      'using "fallback.otf" instead.\n',
      "The systemfonts package could not be loaded, ",
      "which may be why the font lookup failed:\n",
      'without it, the font files in "',
      dir,
      '" cannot be identified.\n',
      "To use it, install systemfonts 1.3.0 or later ",
      'with `install.packages("systemfonts")`,\n',
      'or check that the folder "',
      dir,
      '" from the option `zueridown.font_path` holds its font files.\n',
      "If its font files are among those that cannot be identified, ",
      "copy them to a folder,\n",
      "rename them to the font names that are looked up, ",
      'such as "TeXGyreHeros-Italic.otf",\n',
      'and set `options(zueridown.font_path = "<folder>")`.\n'
    ),
    fixed = TRUE
  )
  expect_identical(fonts, list(mainfont = "fallback.otf"))

  # a named font is left to LaTeX when the installed fonts cannot be listed,
  # because LaTeX finds the fonts that are installed by name,
  # but not those among the unidentified files in the folder of the option
  local_mocked_bindings(installed_fonts = function(...) NULL)
  expect_message(
    fonts <- resolve_fonts(
      list(mainfont = "TeXGyreHeros-Bold"),
      defaults,
      font_path = dir
    ),
    paste0(
      'Font "TeXGyreHeros-Bold" from the `mainfont` field of the document ',
      "is left to LaTeX, which may not find it.\n",
      "The systemfonts package could not be loaded, ",
      "which may be why the font lookup failed:\n",
      'without it, the font files in "',
      dir,
      '" cannot be identified.\n',
      "If LaTeX does not find it, install systemfonts 1.3.0 or later ",
      'with `install.packages("systemfonts")`,\n',
      "or ",
      font_install_hint("TeXGyreHeros-Bold"),
      ".\n",
      "If its font files are among those that cannot be identified, ",
      "copy them to a folder,\n",
      "rename them to the font names that are looked up, ",
      'such as "TeXGyreHeros-Bold.otf",\n',
      'and set `options(zueridown.font_path = "<folder>")`.\n'
    ),
    fixed = TRUE
  )
  expect_identical(fonts, list(mainfont = "TeXGyreHeros-Bold"))
})

test_that("a family name is loaded from the files of its regular face", {
  skip_if_not_installed("systemfonts", "1.3.0")
  local_mocked_bindings(font_messages = new.env())
  appdata <- withr::local_tempdir()
  user <- copy_fonts(
    file.path(appdata, "Microsoft", "Windows", "Fonts"),
    c(
      "texgyreheros-bolditalic.otf",
      "texgyreheros-bold.otf",
      "texgyreheros-regular.otf",
      "texgyreheros-italic.otf"
    ),
    c("a.otf", "b.otf", "c.otf", "d.otf")
  )
  withr::local_envvar(LOCALAPPDATA = appdata, WINDIR = withr::local_tempdir())
  windows_dirs <- font_dirs("Windows")
  # systemfonts lists the fonts installed for the current user,
  # which LaTeX does not find by name
  local_mocked_bindings(
    font_dirs = function(...) windows_dirs,
    installed_fonts = function(...) {
      list(
        path = file.path(user, "c.otf"),
        name = "TeXGyreHeros-Regular",
        family = "TeX Gyre Heros"
      )
    }
  )

  expect_identical(
    resolve_fonts(list(mainfont = "TeX Gyre Heros"), licensed_defaults),
    list(
      mainfont = "c.otf",
      mainfontoptions = c(
        paste0("Path=", user, "/"),
        "BoldFont=b.otf",
        "ItalicFont=d.otf",
        "BoldItalicFont=a.otf"
      )
    )
  )

  # without systemfonts, the message names the folder,
  # and explains how to do without it next to the usual advice,
  # as with TeX Live's fc-list on Windows, which does not see the folder
  local_systemfonts()
  local_mocked_bindings(installed_fonts = no_fonts)
  unidentified <- paste0(
    "The systemfonts package could not be loaded, ",
    "which may be why the font lookup failed:\n",
    'without it, the font files in "',
    user,
    '" cannot be identified.\n'
  )
  expect_message(
    fonts <- resolve_fonts(
      list(mainfont = "TeX Gyre Heros"),
      licensed_defaults
    ),
    unidentified,
    fixed = TRUE
  )
  expect_identical(fonts, list(mainfont = "fallback.otf"))
  expect_message(
    resolve_fonts(list(), licensed_defaults),
    paste0(
      'Preferred font "HelveticaNeueLTPro-Md" was not found, ',
      'using "fallback.otf" instead.\n',
      unidentified,
      "To use it, install systemfonts 1.3.0 or later ",
      'with `install.packages("systemfonts")`,\n',
      "or ",
      preferred_font_hint("HelveticaNeueLTPro-Md", NULL),
      ".\n",
      "If its font files are among those that cannot be identified, ",
      "copy them to a folder,\n",
      "rename them to the font names that are looked up, ",
      'such as "HelveticaNeueLTPro-Md.otf",\n',
      'and set `options(zueridown.font_path = "<folder>")`.\n'
    ),
    fixed = TRUE
  )
})

test_that("unidentified font files count against a named font only on Windows", {
  # no list of the installed fonts, and no systemfonts to identify font files
  local_systemfonts()
  local_mocked_bindings(
    installed_fonts = function(...) NULL,
    font_messages = new.env()
  )
  appdata <- withr::local_tempdir()
  withr::local_envvar(LOCALAPPDATA = appdata, WINDIR = withr::local_tempdir())
  windows_dirs <- font_dirs("Windows")
  mac_dirs <- font_dirs("Darwin")

  # on Windows, a font installed for the current user may be among
  # the unidentified font files, and LaTeX does not find it by name
  user <- copy_fonts(
    file.path(appdata, "Microsoft", "Windows", "Fonts"),
    "texgyreheros-regular.otf",
    "SomeOtherFont.otf"
  )
  local_mocked_bindings(font_dirs = function(...) windows_dirs)
  expect_message(
    fonts <- resolve_fonts(list(mainfont = "Arial"), licensed_defaults),
    paste0(
      'Font "Arial" from the `mainfont` field of the document could not be verified, ',
      'using "fallback.otf" instead.\n',
      "The systemfonts package could not be loaded, ",
      "which may be why the font lookup failed:\n",
      'without it, the font files in "',
      user,
      '" cannot be identified.\n',
      "To use it, install systemfonts 1.3.0 or later ",
      'with `install.packages("systemfonts")`,\n',
      "or ",
      font_install_hint("Arial"),
      ".\n",
      "If its font files are among those that cannot be identified, ",
      "copy them to a folder,\n",
      "rename them to the font names that are looked up, ",
      'such as "Arial.otf",\n',
      'and set `options(zueridown.font_path = "<folder>")`.\n'
    ),
    fixed = TRUE
  )
  expect_identical(fonts, list(mainfont = "fallback.otf"))
  # without font files there, it is left to LaTeX
  unlink(file.path(user, "SomeOtherFont.otf"))
  expect_silent(
    fonts <- resolve_fonts(list(mainfont = "Arial"), licensed_defaults)
  )
  expect_identical(fonts, list(mainfont = "Arial"))

  # elsewhere, LaTeX finds an installed font by name
  local_mocked_bindings(font_dirs = function(...) mac_dirs)
  expect_silent(
    fonts <- resolve_fonts(list(mainfont = "Helvetica"), licensed_defaults)
  )
  expect_identical(fonts, list(mainfont = "Helvetica"))

  # on macOS and Linux, it could not be verified
  # if the faces of its font files cannot be told apart
  local_mocked_bindings(font_dirs = function(...) mac_dirs)
  folder <- copy_fonts(
    withr::local_tempdir(),
    "texgyreheros-regular.otf",
    "Arial.otf"
  )
  withr::local_options(zueridown.font_path = folder)
  expect_message(
    fonts <- resolve_fonts(list(mainfont = "Arial"), licensed_defaults),
    paste0(
      'Font "Arial" from the `mainfont` field of the document could not be verified, ',
      'using "fallback.otf" instead.\n'
    ),
    fixed = TRUE
  )
  expect_identical(fonts, list(mainfont = "fallback.otf"))
  # also next to unidentified font files in the folder of the option,
  # which may hold the font under other names, as the message explains
  dir <- copy_fonts(
    withr::local_tempdir(),
    licensed_files,
    c("Helvetica Neue 65 Medium.otf", "Helvetica Neue 85 Heavy.otf")
  )
  expect_message(
    fonts <- resolve_fonts(
      list(mainfont = "Helvetica"),
      licensed_defaults,
      font_path = dir
    ),
    paste0(
      "is left to LaTeX, which may not find it.\n",
      "The systemfonts package could not be loaded"
    ),
    fixed = TRUE
  )
  expect_identical(fonts, list(mainfont = "Helvetica"))
})

test_that("systemfonts is not needed for fonts found otherwise", {
  skip_on_os(c("windows", "mac"))
  local_systemfonts("1.2.3")
  local_mocked_bindings(font_messages = new.env())
  # an unrelated font in a user folder, the licensed font in a system folder
  home <- withr::local_tempdir()
  system <- withr::local_tempdir()
  copy_fonts(file.path(home, "fonts"), "texgyreheros-regular.otf", "other.otf")
  dir <- copy_fonts(file.path(system, "fonts"), licensed_files, licensed_names)
  local_mocked_bindings(
    font_dirs = function(...) {
      list(user = file.path(home, "fonts"), system = system)
    },
    installed_fonts = no_fonts
  )
  expect_silent(fonts <- resolve_fonts(list(), licensed_defaults))
  expect_loaded_from(fonts, dir)

  # a missing font, with a list of the installed fonts
  unlink(dir, recursive = TRUE)
  expect_message(
    fonts <- resolve_fonts(list(), licensed_defaults),
    "To use it, copy its font files to ~/.local/share/fonts,",
    fixed = TRUE
  )
  expect_identical(fonts, list(mainfont = "fallback.otf"))
})

test_that("an installed font named in the document is loaded by name", {
  # on Linux, LaTeX finds the fonts in the user's folders by name,
  # with their bold and italic faces
  home <- local_linux_dirs()
  copy_fonts(
    file.path(home, ".local", "share", "fonts"),
    licensed_files,
    licensed_names
  )
  local_mocked_bindings(
    installed_fonts = function(...) {
      list(path = "x.otf", name = "HelveticaNeueLTPro-Md", family = "x")
    }
  )
  expect_identical(
    resolve_fonts(list(mainfont = "HelveticaNeueLTPro-Md"), licensed_defaults),
    list(mainfont = "HelveticaNeueLTPro-Md")
  )
})

test_that("the message is shown again if its advice changes", {
  local_mocked_bindings(
    font_dirs = function(...) list(),
    installed_fonts = no_fonts,
    font_messages = new.env()
  )
  expect_message(resolve_fonts(list(), licensed_defaults), "was not found")
  expect_silent(resolve_fonts(list(), licensed_defaults))
  expect_message(
    resolve_fonts(list(), licensed_defaults, font_path = "/no/fonts/a"),
    "/no/fonts/a",
    fixed = TRUE
  )
  expect_message(
    resolve_fonts(list(), licensed_defaults, font_path = "/no/fonts/b"),
    "/no/fonts/b",
    fixed = TRUE
  )
})

test_that("the option zueridown.system_fonts hides the installed fonts", {
  skip_on_os(c("windows", "mac"))
  skip_if_not_installed("systemfonts")
  home <- withr::local_tempdir()
  withr::local_envvar(HOME = home, XDG_DATA_HOME = "", PATH = R.home("bin"))
  dir <- copy_fonts(
    file.path(home, ".local", "share", "fonts"),
    licensed_files,
    licensed_names
  )
  local_mocked_bindings(font_messages = new.env())
  expect_loaded_from(resolve_fonts(list(), licensed_defaults), dir)

  local_mocked_bindings(
    system_fonts = function(...) stop("systemfonts is not used"),
    .package = "systemfonts"
  )
  withr::local_options(zueridown.system_fonts = FALSE)
  expect_identical(font_dirs("Linux"), list())
  expect_identical(installed_fonts()[c("path", "name", "family")], no_fonts())
  expect_message(
    fonts <- resolve_fonts(list(), licensed_defaults),
    "was not found"
  )
  expect_identical(fonts, list(mainfont = "fallback.otf"))
})

test_that("a font file in the Path= of the document is left as named", {
  local_systemfonts()
  local_mocked_bindings(
    font_dirs = function(...) list(),
    installed_fonts = no_fonts,
    font_messages = new.env()
  )
  document <- copy_fonts(withr::local_tempdir(), licensed_files, licensed_names)
  other <- copy_fonts(withr::local_tempdir(), licensed_files, licensed_names)
  faces <- c(
    "BoldFont=HelveticaNeueLTPro-Hv.otf",
    "ItalicFont=*",
    "BoldItalicFont=HelveticaNeueLTPro-Hv.otf"
  )
  named <- list(
    mainfont = "HelveticaNeueLTPro-Md.otf",
    mainfontoptions = c(paste0("Path=", document, "/"), faces)
  )

  # the file is in the folder of the document, which is also in the option
  expect_silent(
    fonts <- resolve_fonts(named, licensed_defaults, font_path = other)
  )
  expect_identical(fonts, named)

  # otherwise it is loaded from the folder of the option, with one Path= only
  named$mainfontoptions[[1]] <- paste0("Path=", withr::local_tempdir(), "/")
  expect_silent(
    fonts <- resolve_fonts(named, licensed_defaults, font_path = other)
  )
  expect_identical(fonts$mainfont, "HelveticaNeueLTPro-Md.otf")
  expect_identical(
    sum(grepl("^Path=", fonts$mainfontoptions)),
    1L
  )
  expect_identical(fonts$mainfontoptions[[1]], paste0("Path=", other, "/"))
})

# A kpsewhich that finds only the font file `found`, first in the PATH
local_kpsewhich <- function(found, .env = parent.frame()) {
  bin <- withr::local_tempdir(.local_envir = .env)
  writeLines(
    c(
      "#!/bin/sh",
      sprintf("[ \"$1\" = '%s' ] && echo '/texmf/%s'", found, found)
    ),
    file.path(bin, "kpsewhich")
  )
  Sys.chmod(file.path(bin, "kpsewhich"), "755")
  withr::local_envvar(
    PATH = paste(bin, Sys.getenv("PATH"), sep = .Platform$path.sep),
    .local_envir = .env
  )
}

test_that("a font file in a relative Path= of the document is left as named", {
  local_mocked_bindings(
    font_dirs = function(...) list(),
    installed_fonts = no_fonts,
    font_messages = new.env()
  )
  withr::local_dir(withr::local_tempdir())
  copy_fonts("fonts", "texgyreheros-regular.otf", "myfont.otf")

  # the reproduction from the review
  expect_silent(
    args <- apply_default_yaml(
      list(mainfont = "myfont.otf", mainfontoptions = "Path=fonts/")
    )
  )
  expect_true("mainfont:myfont.otf" %in% args)
  expect_true("mainfontoptions:Path=fonts/" %in% args)

  # also with an `Extension=`, which fontspec appends to the name,
  # and with spaces and braces that fontspec removes
  named <- list(
    mainfont = "myfont",
    mainfontoptions = c(" Path = {fonts/} ", "Extension=.otf", "Scale=0.9")
  )
  expect_silent(fonts <- resolve_fonts(named, licensed_defaults))
  expect_identical(fonts, named)
})

test_that("a font file name with an Extension= is looked up in the TeX tree", {
  skip_on_os("windows")
  local_mocked_bindings(
    font_dirs = function(...) list(),
    installed_fonts = no_fonts,
    font_messages = new.env()
  )
  withr::local_dir(withr::local_tempdir())
  local_kpsewhich("found.otf")

  named <- list(mainfont = "found", mainfontoptions = "Extension=.otf")
  expect_silent(fonts <- resolve_fonts(named, licensed_defaults))
  expect_identical(fonts, named)

  # a missing one, also if a font of that name is installed
  local_mocked_bindings(installed_font_names = function(...) "missing")
  named$mainfont <- "missing"
  expect_message(
    fonts <- resolve_fonts(named, licensed_defaults),
    paste0(
      'Font "missing" from the `mainfont` field of the document was not found, ',
      'using "fallback.otf" instead.\n',
      "To use it, check the path"
    ),
    fixed = TRUE
  )
  expect_identical(fonts, list(mainfont = "fallback.otf"))

  # with a `Path=`, the file is looked up only in its folder
  named <- list(mainfont = "found.otf", mainfontoptions = "Path=fonts/")
  expect_message(
    fonts <- resolve_fonts(named, licensed_defaults),
    "check the path",
    fixed = TRUE
  )
  expect_identical(fonts, list(mainfont = "fallback.otf"))

  # without kpsewhich, LaTeX has to find it
  withr::local_envvar(PATH = R.home("bin"))
  named <- list(mainfont = "missing", mainfontoptions = "Extension=.otf")
  expect_silent(fonts <- resolve_fonts(named, licensed_defaults))
  expect_identical(fonts, named)
})

test_that("a font file name is looked up in the TeX tree", {
  skip_on_os("windows")
  local_mocked_bindings(
    font_dirs = function(...) list(),
    installed_fonts = no_fonts,
    font_messages = new.env()
  )
  withr::local_dir(withr::local_tempdir())
  local_kpsewhich("found.otf")

  expect_silent(
    fonts <- resolve_fonts(list(mainfont = "found.otf"), licensed_defaults)
  )
  expect_identical(fonts, list(mainfont = "found.otf"))
  expect_message(
    fonts <- resolve_fonts(list(mainfont = "missing.otf"), licensed_defaults),
    'Font "missing.otf" from the `mainfont` field of the document was not found',
    fixed = TRUE
  )
  expect_identical(fonts, list(mainfont = "fallback.otf"))

  # without kpsewhich, LaTeX has to find it
  withr::local_envvar(PATH = R.home("bin"))
  expect_silent(
    fonts <- resolve_fonts(list(mainfont = "missing.otf"), licensed_defaults)
  )
  expect_identical(fonts, list(mainfont = "missing.otf"))
})

test_that("an Extension= is replaced if the font is loaded from another folder", {
  local_mocked_bindings(
    font_dirs = function(...) list(),
    installed_fonts = no_fonts,
    font_messages = new.env()
  )
  dir <- copy_fonts(withr::local_tempdir(), licensed_files, licensed_names)
  named <- list(
    mainfont = "HelveticaNeueLTPro-Md",
    mainfontoptions = c(
      "Path=nowhere/",
      "Extension=.otf",
      "BoldFont=HelveticaNeueLTPro-Hv",
      "ItalicFont=*",
      "BoldItalicFont=HelveticaNeueLTPro-Hv"
    )
  )
  expect_silent(
    fonts <- resolve_fonts(named, licensed_defaults, font_path = dir)
  )
  expect_identical(
    fonts,
    list(
      mainfont = "HelveticaNeueLTPro-Md.otf",
      mainfontoptions = c(
        paste0("Path=", dir, "/"),
        "BoldFont=HelveticaNeueLTPro-Hv.otf",
        "ItalicFont=HelveticaNeueLTPro-Md.otf",
        "BoldItalicFont=HelveticaNeueLTPro-Hv.otf"
      )
    )
  )
})

test_that("a missing font named in the document falls back without its options", {
  local_mocked_bindings(
    font_dirs = function(...) list(),
    installed_fonts = no_fonts,
    installed_font_names = function(...) "Some Sans",
    font_messages = new.env()
  )
  expect_message(
    args <- apply_default_yaml(
      list(mainfont = "Missing Sans", mainfontoptions = "Scale=0.9")
    ),
    paste0(
      'Font "Missing Sans" from the `mainfont` field of the document was not found, ',
      'using "texgyreheros-regular.otf" instead.\n',
      "To use it, ",
      font_install_hint("Missing Sans"),
      ".\n"
    ),
    fixed = TRUE
  )
  expect_true("mainfont:texgyreheros-regular.otf" %in% args)
  expect_match(
    args,
    "^mainfontoptions:Path=.*/fonts/,.*BoldItalicFont=texgyreheros-bolditalic[.]otf$",
    all = FALSE
  )
})

test_that("the format repeats the font message after the output is written", {
  skip_if_not(rmarkdown::pandoc_available(), "pandoc not available")
  local_mocked_bindings(
    font_dirs = function(...) list(),
    installed_fonts = no_fonts,
    installed_font_names = function(...) "Some Sans",
    font_messages = new.env()
  )
  input <- file.path(withr::local_tempdir(), "doc.Rmd")
  writeLines(c("---", "mainfont: Missing Sans", "---", "", "Text."), input)
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
  font <- grep('"Missing Sans"', messages, fixed = TRUE)
  expect_length(font, 2)
  expect_identical(messages[[font[[1]]]], messages[[font[[2]]]])
  # the last message, after the "Output created" line
  expect_identical(font[[2]], length(messages))
  expect_match(messages[[font[[2]] - 1]], "Output created")

  # a render without the message does not repeat it
  messages <- render()
  expect_false(any(grepl("Missing Sans", messages, fixed = TRUE)))
})

test_that("the font message is not repeated if the output is not written", {
  local_mocked_bindings(
    font_dirs = function(...) list(),
    installed_fonts = no_fonts,
    installed_font_names = function(...) "Some Sans",
    font_messages = new.env()
  )
  format <- zueridown()
  expect_message(
    format$pre_processor(
      list(mainfont = "Missing Sans"),
      "doc.knit.md",
      "static",
      list(),
      "doc_files",
      "."
    ),
    "not found"
  )
  expect_silent(format$on_exit())
})

test_that("a folder is written for fontspec in Path=", {
  expect_identical(fontspec_path("/a b/fonts/"), "/a b/fonts/")
  expect_identical(
    fontspec_path("/a  b/fonts/"),
    "/a\\csname c_space_tl\\endcsname \\csname c_space_tl\\endcsname b/fonts/"
  )
  expect_identical(
    fontspec_path("/a b,c=d/%#~{}^\\/", windows = FALSE),
    paste0(
      "{/a\\csname c_space_tl\\endcsname b,c=d/",
      "\\csname c_percent_str\\endcsname ",
      "\\csname c_hash_str\\endcsname ",
      "\\csname c_tilde_str\\endcsname ",
      "\\csname c_left_brace_str\\endcsname ",
      "\\csname c_right_brace_str\\endcsname ",
      "\\csname c_circumflex_str\\endcsname ",
      "\\csname c_backslash_str\\endcsname /}"
    )
  )
  expect_identical(
    fontspec_path(c("C:\\Fonts, A\\", "C:/B/"), windows = TRUE),
    c("{C:/Fonts, A/}", "C:/B/")
  )
})

test_that("fonts are loaded from folders with special characters in their paths", {
  skip_on_cran()
  skip_if_not_installed("pdftools")
  skip_if_not(rmarkdown::pandoc_available(), "pandoc not available")
  skip_if_not(nzchar(Sys.which("xelatex")), "xelatex not available")
  local_mocked_bindings(
    font_dirs = function(...) list(),
    installed_fonts = no_fonts,
    font_messages = new.env()
  )
  # the package in a library with such a path,
  # which YAML would also read otherwise, as a comment
  special <- file.path(withr::local_tempdir(), "a, b=c%d #e~f{g}h^i")
  dir.create(special)
  file.copy(indiedown_path(), special, recursive = TRUE)
  local_mocked_bindings(
    indiedown_path = function(...) file.path(special, "indiedown", ...)
  )
  input <- file.path(withr::local_tempdir(), "fonts.Rmd")
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
    sub("^[A-Z]{6}[+](.*?)(-Identity-H)?$", "\\1", fonts$name[fonts$embedded])
  }

  # the fallback font, from the package
  messages <- capture_messages(fonts <- embedded_fonts())
  expect_match(messages, "was not found", all = FALSE)
  expect_true(
    all(c("TeXGyreHeros-Regular", "TeXGyreHeros-Bold") %in% fonts)
  )

  # the preferred font, from the folder of the option
  withr::local_options(
    zueridown.font_path = copy_fonts(
      file.path(special, "fonts"),
      licensed_files,
      licensed_names
    )
  )
  fonts <- embedded_fonts()
  expect_true(
    all(c("TeXGyreHeros-Italic", "TeXGyreHeros-BoldItalic") %in% fonts)
  )
  expect_false("TeXGyreHeros-Regular" %in% fonts)
})

test_that("fontspec options in one string are split at commas outside braces", {
  expect_null(split_font_options(NULL))
  expect_null(split_font_options(""))
  expect_identical(
    split_font_options(c(
      "Path={/a,b=c}/,BoldFont=x.otf, Scale=0.9",
      "Color=red"
    )),
    c("Path={/a,b=c}/", "BoldFont=x.otf", "Scale=0.9", "Color=red")
  )
  expect_identical(split_font_options(list("A=1", "B=2")), c("A=1", "B=2"))
})

test_that("a font file in a Path= of the document written as one string is left as named", {
  local_systemfonts()
  local_mocked_bindings(
    font_dirs = function(...) list(),
    installed_fonts = no_fonts,
    font_messages = new.env()
  )
  document <- copy_fonts(withr::local_tempdir(), licensed_files, licensed_names)
  named <- list(
    mainfont = "HelveticaNeueLTPro-Md.otf",
    mainfontoptions = paste0(
      "Path=",
      document,
      "/,BoldFont=HelveticaNeueLTPro-Hv.otf,Scale=0.9"
    )
  )
  expect_silent(fonts <- resolve_fonts(named, licensed_defaults))
  expect_identical(fonts$mainfont, "HelveticaNeueLTPro-Md.otf")
  expect_identical(
    fonts$mainfontoptions,
    c(
      paste0("Path=", document, "/"),
      "BoldFont=HelveticaNeueLTPro-Hv.otf",
      "Scale=0.9"
    )
  )
})

test_that("a default.yaml with the font options in one string is rendered", {
  skip_on_cran()
  skip_if_not_installed("pdftools")
  skip_if_not(rmarkdown::pandoc_available(), "pandoc not available")
  skip_if_not(nzchar(Sys.which("xelatex")), "xelatex not available")
  local_mocked_bindings(
    font_dirs = function(...) list(),
    installed_fonts = no_fonts,
    font_messages = new.env()
  )
  # the package in a library with two spaces in the path
  library <- file.path(withr::local_tempdir(), "two  spaces")
  dir.create(library)
  file.copy(indiedown_path(), library, recursive = TRUE)
  local_mocked_bindings(
    indiedown_path = function(...) file.path(library, "indiedown", ...)
  )
  yaml_file <- file.path(library, "indiedown", "default.yaml")
  lines <- readLines(yaml_file)
  start <- grep("^mainfontoptions:", lines)
  end <- start + 4
  stopifnot(grepl("^- ", lines[start + 1]), !grepl("^- ", lines[end + 1]))
  lines <- c(
    lines[seq_len(start - 1)],
    paste0(
      "mainfontoptions: \"Path=<<indiedown_path>>/fonts/,",
      "BoldFont=texgyreheros-bold.otf,ItalicFont=texgyreheros-italic.otf,",
      "BoldItalicFont=texgyreheros-bolditalic.otf\""
    ),
    lines[-seq_len(end)]
  )
  writeLines(lines, yaml_file)

  input <- file.path(withr::local_tempdir(), "fonts.Rmd")
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
  suppressMessages(
    pdf <- rmarkdown::render(input, quiet = TRUE, envir = new.env())
  )
  fonts <- pdftools::pdf_fonts(pdf)
  fonts <- sub(
    "^[A-Z]{6}[+](.*?)(-Identity-H)?$",
    "\\1",
    fonts$name[fonts$embedded]
  )
  expect_true(
    all(
      c("TeXGyreHeros-Regular", "TeXGyreHeros-Bold", "TeXGyreHeros-Italic") %in%
        fonts
    )
  )
})

test_that("the hints ask to restart R, which systemfonts needs to see new fonts", {
  for (sysname in c("Windows", "Darwin", "Linux")) {
    expect_match(font_install_hint("Arial", sysname), "and restart R$")
  }
})

test_that("the lookup lists the installed fonts once and each folder once per font", {
  skip_on_os(c("windows", "mac"))
  # XDG_DATA_HOME is ~/.local/share, as by default
  home <- withr::local_tempdir()
  local_linux_dirs(home, xdg = file.path(home, ".local", "share"))
  local_mocked_bindings(font_messages = new.env())
  calls <- new.env()
  calls$fonts <- 0
  calls$dirs <- character()
  local_mocked_bindings(
    installed_fonts = function(...) {
      calls$fonts <- calls$fonts + 1
      no_fonts()
    },
    list_font_files = function(dir, ...) {
      calls$dirs <- c(calls$dirs, dir)
      character()
    }
  )

  expect_message(resolve_fonts(list(mainfont = "Missing"), licensed_defaults))
  expect_identical(calls$fonts, 1)
  expect_identical(
    calls$dirs,
    c(
      file.path(home, ".local", "share", "fonts"),
      file.path(home, ".fonts"),
      normalizePath(c("/usr/local/share/fonts", "/usr/share/fonts"), "/", FALSE)
    )
  )
})

test_that("PostScript names are read once per file and session", {
  skip_if_not_installed("systemfonts", "1.3.0")
  dir <- copy_fonts(withr::local_tempdir(), licensed_files, c("a.otf", "b.otf"))
  files <- file.path(dir, c("a.otf", "b.otf"))
  read <- 0
  font_info <- systemfonts::font_info
  local_mocked_bindings(
    font_info = function(...) {
      read <<- read + 1
      font_info(...)
    },
    .package = "systemfonts"
  )

  names <- list(
    path = files[c(1, 2, 1)],
    name = c("TeXGyreHeros-Italic", "TeXGyreHeros-BoldItalic", "TeX Gyre Heros")
  )
  expect_identical(font_file_names(files), names)
  expect_identical(read, 2)
  expect_identical(font_file_names(files), names)
  expect_identical(read, 2)

  # again after a change
  Sys.setFileTime(files[[1]], Sys.time() + 60)
  expect_identical(font_file_names(files), names)
  expect_identical(read, 3)

  # a file that is not a font
  writeLines("not a font", file.path(dir, "broken.otf"))
  expect_identical(
    font_file_names(file.path(dir, "broken.otf")),
    list(path = file.path(dir, "broken.otf"), name = NA_character_)
  )
})

test_that("get_indiedown_option() reads the option of the package", {
  expect_identical(indiedown_option_name("font_path"), "zueridown.font_path")
  expect_null(get_indiedown_option("font_path"))
  expect_identical(get_indiedown_option("font_path", "default"), "default")

  withr::local_options(zueridown.font_path = "fonts", indiedown.font_path = "x")
  expect_identical(get_indiedown_option("font_path"), "fonts")
  expect_identical(get_indiedown_option("font_path", "default"), "fonts")
})

test_that("get_indiedown_option() falls back to indiedown without a package", {
  # a file that is sourced, not part of a package
  expect_identical(
    indiedown_option_name("mainfont", globalenv()),
    "indiedown.mainfont"
  )
  expect_identical(
    indiedown_option_name("mainfont", new.env(parent = globalenv())),
    "indiedown.mainfont"
  )
})

test_that("options are defaults in function signatures", {
  expect_identical(
    formals(resolve_fonts)$font_path,
    quote(get_indiedown_option("font_path"))
  )
  local_mocked_bindings(
    font_dirs = function(...) list(),
    installed_fonts = no_fonts
  )
  dir <- copy_fonts(withr::local_tempdir(), licensed_files, licensed_names)
  withr::local_options(zueridown.font_path = dir)
  expect_loaded_from(resolve_fonts(list(), licensed_defaults), dir)
  expect_loaded_from(
    resolve_fonts(list(), licensed_defaults, font_path = dir),
    dir
  )
})

test_that("the option zueridown.mainfont names the main font", {
  local_mocked_bindings(
    installed_font_names = function(...) c("DejaVu Sans", "Other"),
    font_messages = new.env()
  )
  withr::local_options(zueridown.mainfont = "DejaVu Sans")
  expect_identical(
    resolve_fonts(list(), licensed_defaults)$mainfont,
    "DejaVu Sans"
  )
  expect_identical(
    resolve_fonts(list(), licensed_defaults, mainfont = "Other")$mainfont,
    "Other"
  )
  expect_message(
    resolve_fonts(
      list(),
      licensed_defaults,
      mainfont = "Missing",
      font_path = tempfile()
    ),
    'Font "Missing" from the `zueridown.mainfont` option was not found',
    fixed = TRUE
  )
})

test_that("a font in ~/.local/share/fonts is found with fc-list", {
  skip_on_os(c("windows", "mac"))
  skip_if_not(nzchar(Sys.which("fc-list")), "fc-list not available")
  home <- local_linux_dirs()
  dir <- copy_fonts(
    file.path(home, ".local", "share", "fonts"),
    licensed_files,
    licensed_names
  )
  # without systemfonts, only fc-list tells the faces apart:
  # the bold italic face that the options do not name
  # is the italic face closest to the bold one
  local_systemfonts()
  defaults <- licensed_defaults
  defaults$preferredmainfontoptions <- c(
    "BoldFont=HelveticaNeueLTPro-Hv",
    "ItalicFont=HelveticaNeueLTPro-Md"
  )
  expect_silent(fonts <- resolve_fonts(list(), defaults))
  expect_loaded_from(fonts, dir)
  expect_identical(
    fonts$mainfontoptions[-1],
    c(
      "BoldFont=HelveticaNeueLTPro-Hv.otf",
      "ItalicFont=HelveticaNeueLTPro-Md.otf",
      "BoldItalicFont=HelveticaNeueLTPro-Hv.otf"
    )
  )
})

test_that("a font in ~/.local/share/fonts is found without fc-list", {
  skip_on_os(c("windows", "mac"))
  home <- local_linux_dirs()
  withr::local_envvar(PATH = R.home("bin"))
  local_mocked_bindings(installed_fonts = no_fonts)
  dir <- copy_fonts(
    file.path(home, ".local", "share", "fonts"),
    licensed_files,
    licensed_names
  )
  expect_silent(fonts <- resolve_fonts(list(), licensed_defaults))
  expect_loaded_from(fonts, dir)
})

test_that("fonts are found in the other Linux folders", {
  skip_on_os(c("windows", "mac"))
  home <- local_linux_dirs(xdg = withr::local_tempdir())
  expect_identical(
    font_dirs("Linux")$user,
    c(
      "~/.local/share/fonts",
      "~/.fonts",
      file.path(Sys.getenv("XDG_DATA_HOME"), "fonts")
    )
  )
  expect_identical(
    font_dirs("Linux")$system,
    c("/usr/local/share/fonts", "/usr/share/fonts")
  )
  local_mocked_bindings(installed_fonts = no_fonts)

  # in a subfolder of ~/.fonts
  dir <- copy_fonts(
    file.path(home, ".fonts", "vendor", "heros"),
    licensed_files,
    licensed_names
  )
  expect_loaded_from(resolve_fonts(list(), licensed_defaults), dir)
  unlink(file.path(home, ".fonts"), recursive = TRUE)

  dir <- copy_fonts(
    file.path(Sys.getenv("XDG_DATA_HOME"), "fonts"),
    licensed_files,
    licensed_names
  )
  expect_loaded_from(resolve_fonts(list(), licensed_defaults), dir)
})

test_that("the Linux system folders are searched by file name", {
  system <- withr::local_tempdir()
  dir <- copy_fonts(
    file.path(system, "truetype"),
    licensed_files,
    licensed_names
  )
  local_mocked_bindings(
    font_dirs = function(...) {
      list(user = file.path(system, "none"), system = system)
    },
    installed_fonts = no_fonts
  )
  expect_loaded_from(resolve_fonts(list(), licensed_defaults), dir)
})

test_that("the option alone is enough on Linux", {
  skip_on_os(c("windows", "mac"))
  local_linux_dirs()
  withr::local_envvar(PATH = R.home("bin"))
  local_mocked_bindings(installed_fonts = no_fonts)
  dir <- copy_fonts(withr::local_tempdir(), licensed_files, licensed_names)
  withr::local_options(zueridown.font_path = dir)
  expect_silent(fonts <- resolve_fonts(list(), licensed_defaults))
  expect_loaded_from(fonts, dir)
})

test_that("the Linux hint asks to copy the fonts or set the option, not for root", {
  hint <- font_install_hint("HelveticaNeueLTPro-Md", "Linux")
  expect_identical(
    hint,
    "copy its font files to ~/.local/share/fonts, and restart R"
  )
  local_mocked_bindings(
    font_dirs = function(...) list(),
    installed_fonts = function() list(path = "x", name = "x", family = "x"),
    font_messages = new.env()
  )
  expect_message(
    resolve_fonts(list(), licensed_defaults),
    paste0(
      "To use it, copy its font files to ~/.local/share/fonts, and restart R,\n",
      'or set `options(zueridown.font_path = "<folder>")` ',
      "to a folder with its font files.\n"
    ),
    fixed = TRUE
  )
  expect_no_match(hint, "sudo|root|/usr")
})

test_that("the search of font folders is bounded", {
  dir <- withr::local_tempdir()
  deep <- file.path(dir, "a", "b", "c", "d")
  dir.create(deep, recursive = TRUE)
  file.create(file.path(c(dir, deep), "x.ttf"))
  expect_length(list_font_files(dir), 1)
  expect_length(list_font_files(dir, depth = 4), 2)
  files <- file.path(dir, c("a/1.otf", "a/b/2.OTF", "e.txt"))
  file.create(files)
  expect_length(list_font_files(dir, limit = 2), 2)
  expect_length(list_font_files(dir, limit = 1), 1)
})

test_that("a font in ~/.local/share/fonts is embedded, also without fc-list", {
  skip_on_cran()
  skip_on_os(c("windows", "mac"))
  skip_if_not_installed("pdftools")
  skip_if_not(rmarkdown::pandoc_available(), "pandoc not available")
  skip_if_not(nzchar(Sys.which("xelatex")), "xelatex not available")

  home <- local_linux_dirs()
  copy_fonts(
    file.path(home, ".local", "share", "fonts"),
    licensed_files,
    licensed_names
  )
  input <- file.path(withr::local_tempdir(), "fonts.Rmd")
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
  # XeLaTeX needs the real HOME for its caches, but not the fonts there
  withr::local_envvar(
    TEXMFVAR = withr::local_tempdir(),
    TEXMFCACHE = withr::local_tempdir()
  )
  pdf <- rmarkdown::render(input, quiet = TRUE, envir = new.env())
  fonts <- pdftools::pdf_fonts(pdf)
  names <- sub(
    "^[A-Z]{6}[+](.*?)(-Identity-H)?$",
    "\\1",
    fonts$name[fonts$embedded]
  )
  expect_true(all(
    c("TeXGyreHeros-Italic", "TeXGyreHeros-BoldItalic") %in% names
  ))
  expect_false("TeXGyreHeros-Regular" %in% names)
})

# The fonts that XeLaTeX embeds for the pandoc variables `fonts`,
# with text in each face
xelatex_fonts <- function(fonts) {
  dir <- withr::local_tempdir()
  writeLines(
    c(
      "\\documentclass{article}",
      "\\usepackage{fontspec}",
      sprintf(
        "\\setmainfont[%s]{%s}",
        paste(fonts$mainfontoptions, collapse = ","),
        fonts$mainfont
      ),
      "\\begin{document}",
      "Regular \\textbf{bold} \\textit{italic} \\textbf{\\textit{bold italic}}",
      "\\end{document}"
    ),
    file.path(dir, "fonts.tex")
  )
  withr::with_dir(
    dir,
    system2(
      "xelatex",
      c("-interaction=nonstopmode", "fonts.tex"),
      stdout = FALSE,
      stderr = FALSE
    )
  )
  fonts <- pdftools::pdf_fonts(file.path(dir, "fonts.pdf"))
  # without the subset prefix and the encoding
  sort(sub(
    "^[A-Z]{6}[+](.*?)(-Identity-H)?$",
    "\\1",
    fonts$name[fonts$embedded]
  ))
}

heros_faces <- c(
  "TeXGyreHeros-Bold",
  "TeXGyreHeros-BoldItalic",
  "TeXGyreHeros-Italic",
  "TeXGyreHeros-Regular"
)

test_that("the faces that the options do not name are loaded from the family", {
  skip_if_not_installed("systemfonts", "1.3.0")
  local_mocked_bindings(
    font_dirs = function(...) list(),
    installed_fonts = no_fonts,
    font_messages = new.env()
  )
  heros <- c(
    "texgyreheros-regular.otf",
    "texgyreheros-bold.otf",
    "texgyreheros-italic.otf",
    "texgyreheros-bolditalic.otf"
  )
  dir <- copy_fonts(withr::local_tempdir(), heros)
  # a preferred font that names only its bold face, found by file name
  defaults <- list(
    mainfont = "fallback.otf",
    preferredmainfont = "TeXGyreHeros-Regular",
    preferredmainfontoptions = "BoldFont=TeXGyreHeros-Bold"
  )
  expect_silent(fonts <- resolve_fonts(list(), defaults, font_path = dir))
  expect_identical(
    fonts,
    list(
      mainfont = "texgyreheros-regular.otf",
      mainfontoptions = c(
        paste0("Path=", dir, "/"),
        "BoldFont=texgyreheros-bold.otf",
        "ItalicFont=texgyreheros-italic.otf",
        "BoldItalicFont=texgyreheros-bolditalic.otf"
      )
    )
  )

  # a family name, from files whose names differ from the font names
  named <- copy_fonts(
    withr::local_tempdir(),
    heros,
    c("a.otf", "b.otf", "c.otf", "d.otf")
  )
  expect_silent(
    named_fonts <- resolve_fonts(
      list(mainfont = "TeX Gyre Heros"),
      licensed_defaults,
      font_path = named
    )
  )
  expect_identical(
    named_fonts,
    list(
      mainfont = "a.otf",
      mainfontoptions = c(
        paste0("Path=", named, "/"),
        "BoldFont=b.otf",
        "ItalicFont=c.otf",
        "BoldItalicFont=d.otf"
      )
    )
  )

  skip_on_cran()
  skip_if_not_installed("pdftools")
  skip_if_not(nzchar(Sys.which("xelatex")), "xelatex not available")
  expect_identical(xelatex_fonts(fonts), heros_faces)
  expect_identical(xelatex_fonts(named_fonts), heros_faces)
})

test_that("the faces are chosen by family, slant and weight", {
  styles <- list(
    path = paste0(
      "/f/",
      c("r", "m", "mi", "i", "b", "bi", "k", "ki", "o"),
      ".otf"
    ),
    family = c(rep("Sans", 8), "Other Sans"),
    weight = c(80, 100, 100, 80, 200, 200, 210, 210, 200),
    italic = c(FALSE, FALSE, TRUE, TRUE, FALSE, TRUE, FALSE, TRUE, FALSE)
  )
  faces <- c("BoldFont", "ItalicFont", "BoldItalicFont")

  # the bold closest to bold, the italic closest to the weight of the font
  expect_identical(
    other_faces(styles, "/f/m.otf", character(), faces),
    c(
      BoldFont = "/f/b.otf",
      ItalicFont = "/f/mi.otf",
      BoldItalicFont = "/f/bi.otf"
    )
  )
  # the bold italic closest to a named bold face
  expect_identical(
    other_faces(styles, "/f/r.otf", "/f/k.otf", faces[-1]),
    c(ItalicFont = "/f/i.otf", BoldItalicFont = "/f/ki.otf")
  )
  # no bold face heavier than the heaviest
  expect_identical(
    other_faces(styles, "/f/k.otf", character(), faces),
    c(ItalicFont = "/f/ki.otf")
  )
  # a family without italics or bold faces
  expect_identical(
    other_faces(styles, "/f/o.otf", character(), faces),
    character()
  )
  # without the weight of the font
  styles$weight[[1]] <- NA
  expect_null(other_faces(styles, "/f/r.otf", character(), faces))
})

test_that("the faces are told apart by the installed fonts without systemfonts", {
  local_systemfonts()
  dir <- copy_fonts(
    withr::local_tempdir(),
    c("texgyreheros-regular.otf", "texgyreheros-italic.otf"),
    c("TeXGyreHeros-Regular.otf", "TeXGyreHeros-Italic.otf")
  )
  files <- file.path(
    dir,
    c("TeXGyreHeros-Regular.otf", "TeXGyreHeros-Italic.otf")
  )
  # as fc-list lists them, with the weight and slant of fontconfig
  listed <- installed_font_list(
    path = files,
    index = c(0, 0),
    names = list("TeXGyreHeros-Regular", "TeXGyreHeros-Italic"),
    families = list("TeX Gyre Heros", "TeX Gyre Heros"),
    weight = c(80, 80),
    italic = c(FALSE, TRUE)
  )
  local_mocked_bindings(
    font_dirs = function(...) list(),
    installed_fonts = function(...) listed,
    font_messages = new.env()
  )
  defaults <- list(
    mainfont = "fallback.otf",
    preferredmainfont = "TeXGyreHeros-Regular"
  )
  expect_identical(
    resolve_fonts(list(), defaults, font_path = dir)$mainfontoptions,
    c(paste0("Path=", dir, "/"), "ItalicFont=TeXGyreHeros-Italic.otf")
  )

  # all faces named, loaded from the files
  all_named <- c(
    defaults,
    list(
      preferredmainfontoptions = c(
        "BoldFont=*",
        "ItalicFont=TeXGyreHeros-Italic",
        "BoldItalicFont=TeXGyreHeros-Italic"
      )
    )
  )
  local_mocked_bindings(installed_fonts = no_fonts)
  expect_identical(
    resolve_fonts(list(), all_named, font_path = dir)$mainfont,
    "TeXGyreHeros-Regular.otf"
  )

  # otherwise, the faces cannot be told apart
  hint <- paste0(
    "The systemfonts package could not be loaded, ",
    "which may be why the font lookup failed:\n",
    'without it, the bold and italic faces of the font files in "',
    dir,
    '" cannot be identified.\n',
    "To use it, install systemfonts 1.3.0 or later ",
    'with `install.packages("systemfonts")`,\n',
    "or name all faces of the font in its options, ",
    "with `BoldFont=`, `ItalicFont=` and `BoldItalicFont=`.\n"
  )
  expect_message(
    fonts <- resolve_fonts(list(), defaults, font_path = dir),
    paste0(
      'Preferred font "TeXGyreHeros-Regular" was not found, ',
      'using "fallback.otf" instead.\n',
      hint
    ),
    fixed = TRUE
  )
  expect_identical(fonts, list(mainfont = "fallback.otf"))

  # a named font is not left to LaTeX without a list of the installed fonts
  local_mocked_bindings(installed_fonts = function(...) NULL)
  expect_message(
    fonts <- resolve_fonts(
      list(mainfont = "TeXGyreHeros-Regular"),
      licensed_defaults,
      font_path = dir
    ),
    hint,
    fixed = TRUE
  )
  expect_identical(fonts, list(mainfont = "fallback.otf"))
})

test_that("the named instances of variable fonts are not loaded from files", {
  skip_on_os("windows")
  bin <- withr::local_tempdir()
  # fc-list as it lists a variable font with its named instances
  writeLines(
    c(
      "#!/bin/sh",
      "cat <<'EOF'",
      "/f/Var.ttf\t0\tVar-Regular\tVar Regular\tVar\t[0 210]\t0",
      "/f/Var.ttf\t65536\tVar-Regular\tVar Regular\tVar\t80\t0",
      "/f/Var.ttf\t131072\tVar-Bold\tVar Bold\tVar,Var Bold\t200\t0",
      "/f/Sans.ttf\t0\tSans-Regular\tSans Regular,Sans Normal\tSans\t80\t0",
      "EOF"
    ),
    file.path(bin, "fc-list")
  )
  Sys.chmod(file.path(bin, "fc-list"), "755")
  withr::local_envvar(
    PATH = paste(bin, Sys.getenv("PATH"), sep = .Platform$path.sep)
  )

  installed <- installed_fonts()
  expect_identical(
    installed$path,
    c(rep("/f/Var.ttf", 2), rep(NA, 4), rep("/f/Sans.ttf", 3))
  )
  expect_true("Var-Bold" %in% installed_font_names(installed))
  expect_identical(
    installed$styles,
    list(
      path = c("/f/Var.ttf", "/f/Sans.ttf"),
      family = c("Var", "Sans"),
      weight = c(NA, 80),
      italic = c(FALSE, FALSE)
    )
  )

  find <- function(faces) find_font_files(faces, NULL, installed, list())
  expect_null(find("Var-Bold"))
  expect_identical(find("Var-Regular"), c(`Var-Regular` = "/f/Var.ttf"))
  # several names of one font
  expect_identical(
    find(c("Sans-Regular", "Sans Normal")),
    c(`Sans-Regular` = "/f/Sans.ttf", `Sans Normal` = "/f/Sans.ttf")
  )
})

test_that("on Windows, systemfonts lists no fonts of the current user", {
  skip_if_not_installed("systemfonts")
  appdata <- withr::local_tempdir()
  withr::local_envvar(
    LOCALAPPDATA = appdata,
    WINDIR = "C:/Windows",
    PATH = R.home("bin")
  )
  windows_dirs <- font_dirs("Windows")
  user <- gsub("/", "\\", file.path(windows_dirs$user, "sub"), fixed = TRUE)
  local_mocked_bindings(
    system_fonts = function(...) {
      data.frame(
        path = c(paste0(user, "\\Corp.ttc"), "C:\\Windows\\Fonts\\arial.ttf"),
        index = c(0L, 0L),
        name = c("CorpSans-Medium", "ArialMT"),
        family = c("Corp Sans", "Arial"),
        weight = factor(c("medium", "normal")),
        italic = c(FALSE, FALSE)
      )
    },
    .package = "systemfonts"
  )
  local_mocked_bindings(
    font_dirs = function(...) windows_dirs,
    has_systemfonts = function() TRUE,
    font_messages = new.env()
  )

  installed <- installed_fonts()
  expect_identical(installed$name, "ArialMT")
  expect_identical(installed$styles$weight, 80)
  expect_message(
    fonts <- resolve_fonts(
      list(mainfont = "CorpSans-Medium"),
      licensed_defaults
    ),
    'Font "CorpSans-Medium" from the `mainfont` field of the document was not found',
    fixed = TRUE
  )
  expect_identical(fonts$mainfont, "fallback.otf")
  expect_identical(
    resolve_fonts(list(mainfont = "Arial"), licensed_defaults),
    list(mainfont = "Arial")
  )
})

test_that("the folder of the option comes before the installed fonts", {
  skip_if_not_installed("systemfonts", "1.3.0")
  installed_dir <- copy_fonts(
    withr::local_tempdir(),
    licensed_files,
    licensed_names
  )
  dir <- copy_fonts(withr::local_tempdir(), licensed_files, c("a.otf", "b.otf"))
  local_mocked_bindings(
    font_dirs = function(...) list(),
    installed_fonts = function(...) {
      list(
        path = file.path(installed_dir, licensed_names),
        name = c("TeXGyreHeros-Italic", "TeXGyreHeros-BoldItalic")
      )
    }
  )
  defaults <- list(
    mainfont = "fallback.otf",
    preferredmainfont = "TeXGyreHeros-Italic",
    preferredmainfontoptions = c(
      "BoldFont=TeXGyreHeros-BoldItalic",
      "ItalicFont=*",
      "BoldItalicFont=TeXGyreHeros-BoldItalic"
    )
  )
  expect_identical(
    resolve_fonts(list(), defaults, font_path = dir)$mainfontoptions[[1]],
    paste0("Path=", dir, "/")
  )
  expect_identical(
    resolve_fonts(list(), defaults)$mainfontoptions[[1]],
    paste0("Path=", installed_dir, "/")
  )
})

test_that("the message names the preferred font that is used instead", {
  local_systemfonts()
  local_mocked_bindings(
    font_dirs = function(...) list(),
    installed_fonts = no_fonts,
    font_messages = new.env()
  )
  dir <- copy_fonts(withr::local_tempdir(), licensed_files, licensed_names)
  expect_message(
    fonts <- resolve_fonts(
      list(mainfont = "Missing"),
      licensed_defaults,
      font_path = dir
    ),
    paste0(
      'Font "Missing" from the `mainfont` field of the document was not found, ',
      'using "HelveticaNeueLTPro-Md" instead.\n'
    ),
    fixed = TRUE
  )
  expect_loaded_from(fonts, dir)
})

test_that("paths are compared as on the system", {
  expect_identical(
    path_key("C:\\Users\\Me/Fonts\\A.otf", windows = TRUE),
    "c:/users/me/fonts/a.otf"
  )
  expect_identical(
    path_key("/home/Me\\A.otf", windows = FALSE),
    "/home/Me/A.otf"
  )
  expect_identical(
    in_dirs(
      c("/f/a.otf", "/f/sub/b.otf", "/fonts/c.otf", "/g/d.otf"),
      c("/f", "/g/")
    ),
    c(TRUE, TRUE, FALSE, TRUE)
  )
  expect_identical(in_dirs("/f/a.otf", NULL), FALSE)
})
