pre_processor <- function(
  metadata,
  input_file,
  runtime,
  knit_meta,
  files_dir,
  output_dir
) {
  # apply default.yaml (do not remove)
  args <- apply_default_yaml(metadata = metadata)

  # set the margin based on twocolumn and wide
  if (is.null(metadata$geometry)) {
    if (isTRUE(metadata$twocolumn) || isTRUE(metadata$wide)) {
      args <- c(
        args,
        "--variable",
        "geometry:top=1.7cm,bottom=1.7cm,left=1.3cm,right=1.3cm,includehead,includefoot"
      )
    } else {
      args <- c(
        args,
        "--variable",
        "geometry:top=1.7cm,bottom=1.7cm,left=1.3cm,right=1.3cm,includehead,includefoot"
      )
    }
  }

  # pass twocolumn as classoption
  if (isTRUE(metadata$twocolumn)) {
    args <- c(
      args,
      "--variable",
      paste0("classoption:", metadata$classoption, "twocolumn", collapse = ",")
    )
  }

  args
}
