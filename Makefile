##########################
# General purpose commands
##########################

# Argument fix workaround
######################################
# To use arguments with make, execute:
# make -- <command> <args>
######################################
%:
	@:
ARGS = $(filter-out $@,$(MAKECMDGOALS))
MAKEFLAGS += --silent

# Get the root dir of this file
ROOT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

# Define the full path to this file
THIS_FILE := $(lastword $(MAKEFILE_LIST))

# list available make commands
list:
	sh -c "echo; $(MAKE) -p no_targets__ | awk -F':' '/^[a-zA-Z0-9][^\$$#\/\\t=]*:([^=]|$$)/ {split(\$$1,A,/ /);for(i in A)print A[i]}' | grep -v '__\$$' | grep -v 'Makefile'| sort"

# Find or create a home for sensitive environment variables
CREDS=$(HOME)/.credentials
ifneq ("$(wildcard $(CREDS))","")
CREDENTIALS := $(CREDS)
else
$(info $(shell "mkdir" $(CREDS)))
endif

# # create .env from .env-sample if .env does not exist
# FILE := $(ROOT_DIR)/.env
# FILE_TEMPLATE := $(ROOT_DIR)/.env-sample
# ifneq ("$(wildcard $(FILE))","")
# # $(info "file exists")
# else
# # $(info "file does not exist")
# $(shell "cp" $(FILE_TEMPLATE) $(FILE))
# endif

########################################################
# Configuration options for various Windows environments
########################################################

# # Check if this is Windows
# ifneq (,$(findstring WINDOWS,$(PATH)))
# WINDOWS := True
# endif

# # Set shell to cmd on windows
# ifdef WINDOWS
# SHELL := C:/Windows/System32/cmd.exe
# endif

# # Don't use sudo on windows
# SUDO := sudo
# ifdef WINDOWS
# SUDO := 
# endif

# # set home dir to user's home on windows running MINGW
# ifdef MSYSTEM
# HOME := $(subst \,/,$(HOME))
# endif

#############################
# Application commands
#############################

# Find or create a home for jupyter custom settings
JUPYTER_DIR=$(HOME)/.jupyter/lab/user-settings
ifneq ("$(wildcard $(JUPYTER_DIR))","")
else 
$(info $(shell "mkdir" $(JUPYTER_DIR)))
endif
JUPYTER_SETTINGS := $(JUPYTER_DIR)

# image name to use in the format org/name:tag
APP_IMAGE=pittvax/pv-conda

# container name to use for app
APP_NAME=pv-conda

# docker or docker-compose
DOCKER_CMD=docker
#############################
# Docker commands
#############################

# Build app image as defined in Dockerfile
build :
	@echo "Building image..."
	docker build -t $(APP_IMAGE) .
	# @$(MAKE) -f $(THIS_FILE) up

# build app as defined in docker-compose.yml  
# up:
# 	docker-compose up -d 

up : 
	$(MAKE) -f $(THIS_FILE) stop
	-docker rm -f $(APP_NAME)
	@echo "Creating conda environment. This may take a few minutes..."
	@docker run --rm -it \
	--name $(APP_NAME) \
	--mount type=bind,source=${PWD}/projects,target=/root/projects \
	--mount type=bind,source=$(JUPYTER_SETTINGS),target=/root/user-settings \
	--mount type=bind,source=$(CREDENTIALS),target=/root/credentials \
	--mount type=volume,source=envs_vol,target=/opt/conda/envs \
	-p 8888:8888/tcp  $(APP_IMAGE)
	@echo "Environment created. Jupyter Lab is available at https://localhost:8888"

# stop app without losing data  
stop:
	-docker-compose stop
	-docker stop $(APP_NAME)


# start app  
# start:
# 	docker-compose start

start :
	@$(DOCKER_CMD) start $(APP_NAME)

# build Docker images defined in docker-compose.yml  
# build:
# 	docker build -t magic8bot .

# stop :
# 	@docker stop pv-conda

# stop and delete all local Docker objects but keep downloaded images
# ALL DATA WILL BE DELETED
# re-build:
# 	-docker-compose down --rmi local -v
# 	docker-compose up -d --build

# stop and delete all Docker objects defined in docker-compose.yml  
# ALL DATA WILL BE DELETED 
# destroy:
# 	-docker-compose stop
# 	-docker-compose rm --force server
# 	-docker-compose rm --force mongodb
# 	-docker-compose rm --force adminmongo
# 	-docker rmi magic8bot
# 	-docker rmi mongo
# 	-docker rmi mrvautin/adminmongo
# 	-docker rmi node:10-alpine
# 	-docker rmi traefik:latest
# 	docker volume prune --force
# 	docker system prune --force

destroy : 
	-docker rmi -f pittvax/conda
	@$(MAKE) -f $(THIS_FILE) prune

# show status of Docker objects defined in docker-compose.yml  
state:
	@echo
	@echo ***Containers***
	docker ps
	@echo
	@echo ***Volumes***
	docker volume ls 
	@echo
	@echo ***Networks***
	docker network ls 

prune :
	-docker container rm -f pv-conda
	@docker volume prune -f
	@docker image prune -f

# show Docker logs  
logs:
	$(DOCKER_CMD) logs $(ARGS)

# open a shell in the application container
shell :
	-@$(MAKE) -f $(THIS_FILE) start
	docker exec -i -t $(APP_NAME) /bin/bash

# open a shell in the application container as admin user  
shellw:
	docker exec -it -u root $$(docker-compose ps -q $(APP_NAME) /bin/sh

# sync clock in container with host's clock
time-sync:
	docker run --rm --privileged alpine hwclock -s
