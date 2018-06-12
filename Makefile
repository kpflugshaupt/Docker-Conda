.PHONY: build jupyter prune shell conda

ifneq (,$(findstring WINDOWS,$(PATH)))
	SHELL := C:/Windows/System32/cmd.exe
endif

default: jupyter

build:
	@echo "Building Anaconda container..."
	docker build -t pittvax/anaconda .
	jupyter

jupyter:
	docker run --rm --name anaconda -v ${PWD}/projects:/opt/projects -p 8888:8888/tcp -it pittvax/anaconda

prune:
	@docker ps -a
	@docker image prune -f
	@docker volume prune -f
	@docker container prune

shell:
	docker run -i -t pittvax/anaconda /bin/bash

conda:
	docker run --rm pittvax/anaconda conda $(filter-out $@,$(MAKECMDGOALS))
%:
	@: