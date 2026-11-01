# Pixel-exact visual snapshots of the rendered PDF. See helper-visual.R for
# the mechanism and how to refresh the reference images. Fixtures use a fixed
# date and static, ASCII content, and avoid zueritheme / network assets, so
# the output is deterministic.

test_that("the title-box cover report looks right", {
  expect_pdf_snapshot(
    "report",
    c(
      "---",
      "title           : \"Report Title\"",
      "subtitle        : \"Subtitle\"",
      "author          : \"cynkra GmbH\"",
      "date            : \"January 1, 2026\"",
      "twocolumn       : false",
      "lang            : en-US",
      "numbersections  : true",
      "output          : zueridown::zueridown",
      "---",
      "",
      "```{r, include = FALSE}",
      "library(knitr)",
      "library(zueridown)",
      "cd_knit_chunk_opts()",
      "```",
      "",
      "```{r, results = 'asis'}",
      "cd_footer(foot_text = \"Statistik Stadt Zurich | Report\")",
      "cd_page_title_box(date = \"January 1, 2026\", title_size = \"40pt\")",
      "```",
      "",
      "# Section",
      "",
      "Regular, **bold**, *italic* and `monospace` text.",
      "",
      "## A table",
      "",
      "```{r, echo = FALSE}",
      "knitr::kable(head(mtcars[, 1:3], 4), format = \"latex\", booktabs = TRUE)",
      "```"
    )
  )
})

test_that("a two-column body looks right", {
  expect_pdf_snapshot(
    "twocolumn",
    c(
      "---",
      "title           : \"Two Column\"",
      "author          : \"cynkra GmbH\"",
      "date            : \"January 1, 2026\"",
      "twocolumn       : true",
      "lang            : en-US",
      "output          : zueridown::zueridown",
      "---",
      "",
      "```{r, include = FALSE}",
      "library(knitr)",
      "library(zueridown)",
      "cd_knit_chunk_opts()",
      "```",
      "",
      "```{r, results = 'asis'}",
      "cd_footer(foot_text = \"Statistik Stadt Zurich | Report\")",
      "```",
      "",
      "# Section",
      "",
      "Regular, **bold**, *italic* and `monospace` text, plus inline math",
      "$a^2 + b^2 = c^2$.",
      "",
      "## A table",
      "",
      "```{r, echo = FALSE}",
      "knitr::kable(head(mtcars[, 1:3], 4), format = \"latex\", booktabs = TRUE)",
      "```"
    )
  )
})

test_that("a figure looks right", {
  expect_pdf_snapshot(
    "figure",
    c(
      "---",
      "title           : \"Figure\"",
      "author          : \"cynkra GmbH\"",
      "date            : \"January 1, 2026\"",
      "twocolumn       : false",
      "lang            : en-US",
      "output          : zueridown::zueridown",
      "---",
      "",
      "```{r, include = FALSE}",
      "library(knitr)",
      "library(zueridown)",
      "cd_knit_chunk_opts()",
      "```",
      "",
      "```{r, results = 'asis'}",
      "cd_footer(foot_text = \"Statistik Stadt Zurich | Report\")",
      "```",
      "",
      "# A base plot",
      "",
      "```{r, echo = FALSE, fig.cap = 'A scatter plot.'}",
      "plot(1:10, (1:10)^2)",
      "```"
    )
  )
})
