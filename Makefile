# Set shell to cmd on windows
ifneq (,$(findstring WINDOWS,$(PATH)))
SHELL := C:/Windows/System32/cmd.exe
endif

# set home dir to user's home on windows running MINGW
ifdef MSYSTEM
HOME := $(subst \,/,$(HOME))
endif

# Get the root dir of this file
ROOT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

# Define the full path to this file
THIS_FILE := $(lastword $(MAKEFILE_LIST))

# Find or create a home for jupyter custom settings
JUPYTER_DIR=$(HOME)/.jupyter/lab/user-settings
ifneq ("$(wildcard $(JUPYTER_DIR))","")
else 
$(info $(shell "mkdir" $(JUPYTER_DIR)))
endif
JUPYTER_SETTINGS := $(JUPYTER_DIR)

# Find or create a home for sensitive environment variables
CREDS=$(HOME)/.credentials
ifneq ("$(wildcard $(CREDS))","")
CREDENTIALS := $(CREDS)
else
$(info $(shell "mkdir" $(CREDS)))
endif

default: up

build :
	-docker rm -f pv-conda
	@echo "Building container..."
	docker build --rm -t pittvax/conda .
	@$(MAKE) -f $(THIS_FILE) up

up :
	@echo "Creating conda environment. This may take a few minutes..."
	@docker run -it \
	--name pv-conda \
	--mount type=bind,source=${PWD}/projects,target=/opt/projects \
	--mount type=bind,source=$(JUPYTER_SETTINGS),target=/opt/user-settings \
	--mount type=bind,source=$(CREDENTIALS),target=/opt/credentials \
	--mount type=volume,source=envs_vol,target=/opt/conda/envs \
	-p 8888:8888/tcp  pittvax/conda
	@echo "Environment created. Jupyter Lab is available at https://localhost:8888"


start :
	@docker start pv-conda

stop :
	@docker stop pv-conda

destroy : 
	-docker rmi -f pittvax/conda
	@$(MAKE) -f $(THIS_FILE) prune

prune :
	-docker container rm -f pv-conda
	@docker volume prune -f
	@docker image prune -f

shell :
	-@$(MAKE) -f $(THIS_FILE) start
	docker exec -i -t pv-conda /bin/bash