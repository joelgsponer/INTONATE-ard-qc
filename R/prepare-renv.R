if (!requireNamespace("renv", quietly = TRUE)) {
  install.packages("renv", repos = "https://cran.rstudio.com")
}
renv::init()
source("renv/activate.R")
renv::restore()
source("R/main.R")
