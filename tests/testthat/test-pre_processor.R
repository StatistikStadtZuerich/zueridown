# The pre-processor turns the document metadata into pandoc arguments.
# `twocolumn` is passed on as a class option, and a `--variable` overrides the
# metadata field of the same name, so the class options of the document must
# be passed on with it, one `--variable classoption:<option>` each.

pre_processor_args <- function(metadata) {
  zueridown()$pre_processor(
    metadata = metadata,
    input_file = NULL,
    runtime = NULL,
    knit_meta = NULL,
    files_dir = NULL,
    output_dir = NULL
  )
}

# The values of all `--variable classoption:<value>` pairs.
classoption_args <- function(args) {
  variables <- args[which(args == "--variable") + 1]
  sub("^classoption:", "", grep("^classoption:", variables, value = TRUE))
}

test_that("twocolumn is the only class option without a classoption", {
  expect_equal(
    classoption_args(pre_processor_args(list(twocolumn = TRUE))),
    "twocolumn"
  )
})

test_that("a single classoption is kept next to twocolumn", {
  expect_equal(
    classoption_args(
      pre_processor_args(list(twocolumn = TRUE, classoption = "landscape"))
    ),
    c("landscape", "twocolumn")
  )
})

test_that("several classoption are all kept next to twocolumn", {
  # character vector, as from a YAML list of scalars
  expect_equal(
    classoption_args(
      pre_processor_args(
        list(twocolumn = TRUE, classoption = c("landscape", "draft", "fleqn"))
      )
    ),
    c("landscape", "draft", "fleqn", "twocolumn")
  )
  # list, as from a YAML list of mixed content
  expect_equal(
    classoption_args(
      pre_processor_args(
        list(twocolumn = TRUE, classoption = list("landscape", "draft"))
      )
    ),
    c("landscape", "draft", "twocolumn")
  )
})

test_that("each class option is a variable of its own", {
  args <- pre_processor_args(
    list(twocolumn = TRUE, classoption = c("landscape", "draft"))
  )
  expect_true(all(
    c(
      "--variable",
      "classoption:landscape",
      "--variable",
      "classoption:draft",
      "--variable",
      "classoption:twocolumn"
    ) %in%
      args
  ))
  # nothing like `classoption:landscapetwocolumn`
  expect_false(any(grepl("landscapetwocolumn|drafttwocolumn", args)))
})

test_that("twocolumn is not added twice", {
  expect_equal(
    classoption_args(
      pre_processor_args(
        list(twocolumn = TRUE, classoption = c("twocolumn", "draft"))
      )
    ),
    c("twocolumn", "draft")
  )
})

test_that("classoption is left to pandoc without twocolumn", {
  expect_equal(
    classoption_args(pre_processor_args(list(classoption = "landscape"))),
    character()
  )
  expect_equal(
    classoption_args(
      pre_processor_args(list(twocolumn = FALSE, classoption = "landscape"))
    ),
    character()
  )
  expect_equal(
    classoption_args(pre_processor_args(list(twocolumn = FALSE))),
    character()
  )
})

skip_if_no_pdf_render <- function() {
  testthat::skip_on_cran()
  testthat::skip_if_not(rmarkdown::pandoc_available(), "no pandoc available")
  testthat::skip_if_not(
    (requireNamespace("tinytex", quietly = TRUE) && tinytex::is_tinytex()) ||
      nzchar(Sys.which("xelatex")),
    "no LaTeX engine (TinyTeX / xelatex) available"
  )
}

# Renders a `twocolumn: true` document, with the YAML lines `classoption` added
# to the front matter, and returns the options of its `\documentclass` and
# the warnings raised while rendering.
render_twocolumn <- function(classoption = character()) {
  dir <- withr::local_tempdir()
  input <- file.path(dir, "doc.Rmd")
  writeLines(
    c(
      "---",
      "title           : \"Two columns\"",
      "twocolumn       : true",
      classoption,
      "lang            : en-US",
      "output          : zueridown::zueridown",
      "---",
      "",
      "# Section",
      "",
      "Some text."
    ),
    input
  )

  warnings <- character()
  withCallingHandlers(
    rmarkdown::render(
      input,
      output_dir = dir,
      output_options = list(keep_tex = TRUE),
      quiet = TRUE,
      envir = new.env()
    ),
    warning = function(w) {
      warnings <<- c(warnings, conditionMessage(w))
      invokeRestart("muffleWarning")
    }
  )

  tex <- paste(readLines(file.path(dir, "doc.tex")), collapse = "\n")
  documentclass <- regmatches(tex, regexpr("\\\\documentclass\\[[^]]*\\]", tex))
  options <- sub("^\\\\documentclass\\[", "", sub("\\]$", "", documentclass))
  list(
    options = trimws(strsplit(options, ",")[[1]]),
    warnings = warnings
  )
}

test_that("a twocolumn document renders with twocolumn and without warnings", {
  skip_if_no_pdf_render()

  out <- render_twocolumn()
  expect_true("twocolumn" %in% out$options)

  # multicol is loaded for `multicols`, but must not warn about the twocolumn
  # class option when it is not used
  expect_false(any(grepl("multicol", out$warnings)))
  expect_false(any(grepl("Unused global option", out$warnings)))
})

test_that("a twocolumn document renders with all its class options", {
  skip_if_no_pdf_render()

  out <- render_twocolumn(c("classoption:", "  - landscape", "  - draft"))
  expect_true(all(c("landscape", "draft", "twocolumn") %in% out$options))

  # LaTeX knows all the options
  expect_false(any(grepl("Unused global option", out$warnings)))
  expect_false(any(grepl("multicol", out$warnings)))
})
