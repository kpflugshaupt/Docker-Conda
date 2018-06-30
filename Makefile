.PHONY: test build jupyter start stop destroy prune shell
# Set shell to cmd on windows
ifneq (,$(findstring WINDOWS,$(PATH)))
SHELL := C:/Windows/System32/cmd.exe
endif

# set home dir to user's home on windows running MINGW
ifdef MSYSTEM
HOME := $(subst \,/,$(HOME))
endif

# Get the root dir of this file
ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

# Define the full path to this file
THIS_FILE := $(lastword $(MAKEFILE_LIST))

# Find or create a home for jupyter custom settings
ifneq ("$(wildcard $(HOME)/.jupyter/lab/user-settings)","")
else 
$(shell mkdir -p $(HOME)/.jupyter/lab/user-settings)
endif
JUPYTER_SETTINGS := $(HOME)/.jupyter/lab/user-settings

# Find or create a home for sensitive environment variables
ifneq ("$(wildcard $(HOME)/.credentials)","")
else 
$(shell mkdir -p $(HOME)/.credentials)
endif
CREDENTIALS := $(HOME)/.credentials

default: jupyter

build :
	-docker rm -f pv-conda
	@echo "Building container..."
	docker build --rm -t pittvax/conda . 
	@$(MAKE) -f $(THIS_FILE) jupyter

jupyter :
	docker run -it \
	--name pv-conda \
	--mount type=bind,source=${PWD}/projects,target=/opt/projects \
	--mount type=bind,source=$(JUPYTER_SETTINGS),target=/opt/user-settings \
	--mount type=bind,source=$(CREDENTIALS),target=/opt/credentials \
	-p 8888:8888/tcp  pittvax/conda

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
	docker exec -i -t pv-conda /bin/bash