# Name for the docker image
IMAGE_NAME=intonate_qc

# Build the Docker image
build:
	docker build --no-cache -t $(IMAGE_NAME) .

# Run the Docker container
run:
	docker run --rm \
	-v $(PWD)/output:/usr/src/app/output \
	$(IMAGE_NAME)

# Run the Docker container interactively
run-interactive:
	docker run --rm -it \
	-v $(PWD)/input:/usr/src/app/input \
	-v $(PWD)/output:/usr/src/app/output \
	-v $(PWD)/R:/usr/src/app/R \
	$(IMAGE_NAME) \
	/bin/bash

# Run renv version
run-renv:
	Rscript --vanilla R/prepare-renv.R
	Rscript R/main.R

# Clean the outputs directory
clean:
	rm -rf output/*

# Phony targets to avoid conflicts with filenames
.PHONY: build run clean
