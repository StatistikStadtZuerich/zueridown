# The licensed font is not available on CI, so the system font lookup is mocked.

test_that("the licensed Helvetica Neue LT Pro is used if it is installed", {
  local_mocked_bindings(
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

test_that("a font named in the document takes precedence", {
  local_mocked_bindings(
    installed_font_names = function() {
      c("DejaVu Sans", "HelveticaNeueLTPro-Md", "HelveticaNeueLTPro-Hv")
    }
  )

  args <- apply_default_yaml(list(mainfont = "DejaVu Sans"))
  expect_true("mainfont:DejaVu Sans" %in% args)
  expect_false(any(grepl("^mainfontoptions:", args)))
})
