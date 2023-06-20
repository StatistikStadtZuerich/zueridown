# zueridown R Markdown template

zueridown makes it easy to generate customized R Markdown PDF documents that follow the corporate design of Stadt Zürich.

zueridown is based on the CRAN package [indiedown](https://cynkra.github.io/indiedown/), which lays down the framework for customization.

## Installation

### Install tinytex

To create a pdf document using zueridown you need some Latex packages. 
To install those packages you can install **tinytex** using the following 
lines of code in R:

```{r}
install.packages('tinytex')
tinytex::install_tinytex()
# to uninstall TinyTeX, run tinytex::uninstall_tinytex() 
```

Tinytex automatically will install all packages need for zueridown. However, 
if you get an error due to some missing package, you can use the following 
helper functions:

```{r}
library(tinytex)
tlmgr_install('psnfss')      # install the psnfss package
tlmgr_update()   
```

But if you still have some trouble, it is better to use:

```{r}
tinytex::reinstall_tinytex()
```

You can find more information on <https://yihui.org/tinytex/>

### Install zueridown

#### From .tar.gz file

To install from a local source file, store `zueridown_main.tar.gz` at an
arbitrary location on your computer.

In RStudio, in the ‘Packages’ pane, click ‘Install’ and select the
option ‘Install from Package Archive File’. Browse to the location of
the file and install it.

Alternatively, you can download the package from <https://github.com/cynkra/zueridown>,
by clicking 'Clone or download'), extract it to any location, e.g., to your Desktop.

Then, run:

```r
remotes::install_local("<path_to_location>/zueridown-master", dependencies = FALSE)
```

#### From GitLab

The package can also be directly installed from here with the appropriate git credentials. If you are already cloning repos from GitLab, you can simply run `remotes::install_git("https://cmp-sdlc.stzh.ch/OE-7035/ssz-da/zueriverse/zueridown")`. Otherwise you need to create a personal access token in your settings, and use this as a password, together with your GitLab username.

## Basic Template

After installation, a new R Markdown template is available in RStudio.
To open, use ‘File’, ‘New File’, ‘R Markdown’. 

![](inst/indiedown/res/file_new_file.png)

Click ‘From Template’ and select one of the templates:

 - ‘zueridown document’. 
 - ‘zueridown document with bibliography or glossary ’.

![](inst/indiedown/res/zueridown_tplt.png)

After saving the file on your computer, you can use the ‘Knit’ button to produce a basic PDF document based on this template.

![](inst/indiedown/res/knit.png)

## Version

To check your version of zueridown, run"

```r
packageVersion("zueridown")
```

## Using other packages from the zueriverse

More zueri-specific packages are available on github: [zueritheme](https://github.com/StatistikStadtZuerich/zueritheme) provides a ggplot-theme that is styled according to the city's CI/CD, [zuericolors](https://github.com/StatistikStadtZuerich/zuericolors) provides the CI/CD colors, and [zuericssstyle](https://github.com/StatistikStadtZuerich/zuericssstyle) has css for styling other types of documents such as html.

Use the remotes package to install these packages directly from github, e.g. for zueritheme `remotes::install_github("StatistikStadtZuerich/zueritheme")`. If you are using renv, then there is no need for remotes: `renv::install("StatistikStadtZuerich/zueritheme")`.
