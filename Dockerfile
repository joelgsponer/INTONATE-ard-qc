# Use rocker/tidyverse as base image
FROM rocker/tidyverse:latest

# Create and set the working directory
WORKDIR /usr/src/app

# Run the main R script
CMD ["Rscript", "R/main.R"]

