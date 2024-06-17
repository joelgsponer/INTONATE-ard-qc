# Intonate QC Docker Image

Please copy the `ADEVENT` `ADLONG` `ADSL` `ADTTE` to the `input` folder (files are loaded via partial matching, so no need to adjust file names as long as they start with the ADEVENT etc.).

This repository contains a Docker setup for the `intonate_qc` application. Below are instructions for building and running the Docker image. Alternative you can run the R script directely.

Either using `renv` first to separate library installation from your system installations:
`Rscript R/install_renv.R`
`Rscript R/main.R`
or simply by directely calling the `main.R`	script:
`Rscript R/main.R`
Of course from within the project folder.

Running the docker container will create three short report in `output`.
1. log.txt (information to be shared with me)
2. log_sensitive.txt (information not to be shared with me, but potentially helpfull to debug)
3. error.txt (in case of errors).


## Docker Image Name
The Docker image is named `intonate_qc`.

## Makefile Commands

### Building the Docker Image
To build the Docker image, execute the following command:

```sh
make build
```
This command builds the Docker image with the name `intonate_qc`.

### Running the Docker Container
To run the Docker container, execute:

```sh
make run
```

This runs the container and mounts the following volumes:
- `$(PWD)/input` to `/usr/src/app/input`
- `$(PWD)/output` to `/usr/src/app/output`
- `$(PWD)/R` to `/usr/src/app/R`

### Running the Docker Container Interactively
To run the Docker container interactively, use the command:

```sh
make run-interactive
```

This is similar to the `run` command but provides an interactive terminal session inside the container.

### Running the renv version
In order to automatically setup and restore the renv verion and run it use
`make run-renv`

### Cleaning the Outputs Directory
To clean the `outputs` directory, execute:

```sh
make clean
```

This removes all files in the `outputs` directory.

## Phony Targets
The following targets are declared as `.PHONY` to avoid conflicts with files of the same name:

- `build`
- `run`
- `clean`

## Makefile Example
Here is the complete Makefile for your reference:

```Makefile
# Name for the docker image
IMAGE_NAME=intonate_qc

# Build the Docker image
build:
	docker build -t $(IMAGE_NAME) .

# Run the Docker container
run:
	docker run --rm \
	-v $(PWD)/input:/usr/src/app/input \
	-v $(PWD)/output:/usr/src/app/output \
	-v $(PWD)/R:/usr/src/app/R \
	$(IMAGE_NAME)

# Run the Docker container interactively
run-interactive:
	docker run --rm -it \
	-v $(PWD)/input:/usr/src/app/input \
	-v $(PWD)/output:/usr/src/app/output \
	-v $(PWD)/R:/usr/src/app/R \
	$(IMAGE_NAME) \
	/bin/bash

# Clean the outputs directory
clean:
	rm -rf outputs/*

# Phony targets to avoid conflicts with filenames
.PHONY: build run clean
```

By following these instructions, you should be able to build, run, and clean your Docker environment for the `intonate_qc` application.

