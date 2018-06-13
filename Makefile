.PHONY: test build jupyter prune shell conda
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
JUPYTER_SETTINGS := $(HOME)/.jupyter/lab/user-settings
else 
$(shell mkdir -p ${PWD}/user-settings)
JUPYTER_SETTINGS := ${PWD}/user-settings
endif

default: jupyter

build :
	@echo "Building Anaconda container..."
	docker build -t pittvax/anaconda . 
	@$(MAKE) -f $(THIS_FILE) jupyter

jupyter :
	docker run \
	-it --rm  \
	--name pv-conda \
	--mount type=bind,source=${PWD}/projects,target=/opt/projects \
	--mount type=bind,source=$(JUPYTER_SETTINGS),target=/opt/user-settings \
	-p 8888:8888/tcp  pittvax/anaconda

prune :
	@docker ps -a
	@docker image prune -f
	@docker volume prune -f
	@docker container prune

shell :
	docker run -i -t --rm pittvax/anaconda /bin/bash

conda :
	docker run --rm pittvax/anaconda conda $(filter-out $@,$(MAKECMDGOALS))
% :
	@: