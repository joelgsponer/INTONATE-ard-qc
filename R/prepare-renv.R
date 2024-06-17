if (!requireNamespace("renv", quietly = TRUE)) {
  install.packages("renv")
}
renv::init()
source("renv/activate.R")
renv::restore()
source("R/main.R")
