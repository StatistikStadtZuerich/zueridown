# A skipped visual test must leave the committed snapshots alone: testthat
# deletes snapshot files that a run did not see, and a skipped test sees none.
# This runs test-visual.R in a throwaway copy of the test directory with the
# skip forced (`NOT_CRAN=false` makes `skip_on_cran()` skip), and checks that
# the copied references survive.

test_that("a skipped visual run keeps the committed snapshots", {
  skip_if_not_installed("callr")

  work <- withr::local_tempdir()
  dir.create(file.path(work, "tests"))
  writeLines(
    c("Package: skiptest", "Config/testthat/edition: 3"),
    file.path(work, "DESCRIPTION")
  )
  tests <- file.path(work, "tests", "testthat")
  dir.create(tests)
  file.copy(test_path(c("helper-visual.R", "test-visual.R")), tests)
  file.copy(test_path("_snaps"), tests, recursive = TRUE)

  snaps <- function() {
    files <- list.files(file.path(tests, "_snaps"), recursive = TRUE)
    stats::setNames(
      unname(tools::md5sum(file.path(tests, "_snaps", files))),
      files
    )
  }
  before <- snaps()
  expect_gt(length(before), 0)

  out <- callr::r(
    function(dir) {
      res <- as.data.frame(testthat::test_dir(
        dir,
        reporter = "silent",
        stop_on_failure = FALSE
      ))
      list(skipped = res$skipped, failed = res$failed)
    },
    args = list(tests),
    # `CI` makes testthat skip the cleanup of unused snapshots altogether.
    env = c(callr::rcmd_safe_env(), NOT_CRAN = "false", CI = "false")
  )

  expect_true(all(out$skipped))
  expect_equal(sum(out$failed), 0)
  expect_equal(snaps(), before)
})
