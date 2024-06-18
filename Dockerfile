# Use rocker/tidyverse as base image
FROM rocker/tidyverse:latest

# Create and set the working directory
WORKDIR /usr/src/app
COPY input/ input/
COPY R/ R/

# Run the main R script
CMD ["Rscript", "--vanilla R/main.R"]

