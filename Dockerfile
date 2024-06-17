# Use rocker/tidyverse as base image
FROM rocker/tidyverse:latest

# Create and set the working directory
WORKDIR /usr/src/app
COPY R/ R/
COPY input/ input/

# Run the main R script
CMD ["Rscript", "--vanilla R/main.R"]

