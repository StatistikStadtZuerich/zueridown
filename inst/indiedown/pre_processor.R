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

  # main font: TeX Gyre Heros, shipped in fonts/ and loaded by file name from
  # the installed package, so that no system font lookup happens;
  # a `mainfont` set in the document takes precedence.
  # Pandoc emits both `\setmainfont` and, because `lang` is set,
  # `\babelfont{rm}` from these variables.
  # Variables override metadata, so `mainfontoptions` from the document
  # are appended rather than dropped.
  if (is.null(metadata[["mainfont"]])) {
    mainfontoptions <- c(
      paste0("Path=", indiedown_path_tex("fonts"), "/"),
      "BoldFont=texgyreheros-bold.otf",
      "ItalicFont=texgyreheros-italic.otf",
      "BoldItalicFont=texgyreheros-bolditalic.otf",
      unlist(metadata[["mainfontoptions"]])
    )
    args <- c(
      args,
      "--variable",
      "mainfont:texgyreheros-regular.otf",
      "--variable",
      paste0("mainfontoptions:", paste(mainfontoptions, collapse = ","))
    )
  }

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

  # pass twocolumn as classoption.
  # A variable overrides the metadata field of the same name,
  # so the `classoption` from the document are passed on as well,
  # one variable per option so that pandoc builds the list itself.
  if (isTRUE(metadata$twocolumn)) {
    classoption <- unique(c(unlist(metadata$classoption), "twocolumn"))
    args <- c(
      args,
      unlist(lapply(classoption, function(x) {
        c("--variable", paste0("classoption:", x))
      }))
    )
  }

  args
}
