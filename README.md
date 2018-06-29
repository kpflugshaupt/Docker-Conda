# Docker-Conda

Dockerized version of [Miniconda 3](https://hub.docker.com/r/continuumio/miniconda3/) for easy analyses.  
Base environment is built from Miniconda and useful packages. Cusomize as necessary for your project.

## Prerequisites

* [Docker](https://docs.docker.com/)
* Some familiarity with the command line.  
* Some familiarity with [Jupyter lab/notebook](http://jupyterlab.readthedocs.io/en/stable/#).  
* A little common sense.  

## Overview

1. Fork this repo to your github account.
1. Follow install instructions to get your project started.  
1. Create a new directory or clone an existing work-in-progress with `environment.yml` to the `projects/` directory.
1. Build this container.  
1. Export an updated `environment.yml` to your project's directory and commit to your fork.  
1. Share your forked repo for reproducable analyses.

## Installation  

1. Download or clone your forked repo to your local machine.
1. Clone or copy any existing work into the `/projects` folder.  
1. Install [docker](https://docs.docker.com/), if necessary (pay attention to Docker requirements)
1. Build the container. `Makefile` provides useful commands in the format `make <command>`  
    * Open a shell in the root of this repo  
    * Run `make build` to build the app  -- Note that running `build` in any form will overwrite your container. Be sure to generate an environment file as described below to rebuild your environment.  
    * If make is not installed on your machine, you can run each command mannualy with copy/paste from the Makefile to your shell. Be sure to pay attention to the variables and substitute manually. EG: to build the container run a command similar to the following:  

```bash
# "make build" is easier, but if you have to, use docker commands similar to this
docker build --rm -t pittvax/conda .  && \
docker run -it \
--name pv-conda \
--mount type=bind,source=${PWD}/projects,target=/opt/projects \
--mount type=bind,source=${PWD}/etc,target=/opt/etc \
--mount type=bind,source=~/.jupyter/lab/user-settings,target=/opt/user-settings \
-p 8888:8888/tcp  pittvax/conda
```

## Usage

1. Run `make start` to start or re-start the container for a new session.  
    * This will start your container where you left off and will not overwrite your environment.  
1. Open https://localhost:8888 to view Jupyter lab  
    * The password is "jupyter" (without the quotes)
    * The big scary warning from your browser about https is normal. You are creating a  self-signed key when you build the container. Self-signed keys make browsers mad. You can safely ignore the warning because you are in control of the Jupyter server and the client which are both on your localhost network. [Read more here.](http://jupyter-notebook.readthedocs.io/en/latest/public_server.html#using-ssl-for-encrypted-communication)
1. Update `environment.yml` if necessary.  
1. Run `make stop` to stop the container at the end of your session.  
1. When the project is complete, clean up with `make prune`. This will remove all leftover docker files.

### Interacting with the container's shell  

You can execute commands in the container to perform tasks such as creating a new environment, installing packages or running scripts using two methods.

* Use the Jupyter lab terminal, or  
* Open a new local terminal and run `make shell` to open a shell in the container. Close this shell with `exit`.  

### Conda environments

This script will build an image based on `continuumio/miniconda3:latest` and install:  

* jupyterlab
* ipykernel
* nb_conda_kernels  
* nbstripout
* nodejs

To add to this base configuration, edit `./etc/base-environment.yml` and new builds will use these specifications.

If one or more project directories with individual `environment.yml` files exist in `./projects` an environment for each project will be created on build. Each environment will be automatically installed into Jupyter lab.

#### Creating a new environment  

Environments keep track of your project requirements and sandbox your code so that others can reproduce your analyses easily. To create a new environemnt:

1. Open a shell in the container by running `make shell` in your local terminal or by opening a new terminal in Jupyter Lab.  
1. Execute `conda create -n <my_environment_name>`. [Help here](https://conda.io/docs/commands/conda-create.html)  
1. Activate the new evironment with `source activate <my_environment_name>`
1. Install required packages using pip, conda or other python package installation method.
1. To see the new evironment in Jupyterlab either re-build the container or execute:
    ``` bash
    conda install -c conda-forge -y ipykernel
    ipython kernel install --name=<my_environment_name>
    ```
    Then select 'shutdown all kernels' from the Kernel menu and refresh the page. Your new environment should appear on the launcher page and in the kernel selection menus.
1. Create an environment file as described below.  

#### Creating an environment file  

Creating an environment file allows one to rebuild the container and install packages automatically.  
From a shell in the container or from the Jupyter lab terminal, run  

```bash  
# Substitute your environment's name for <myenvironment>
conda activate <myenvironment>

# Substitute your project's directory for <myproject>
conda env export > /opt/projects/<myproject>/environment.yml  
```

Your environment configuration can be shared with your source code to rebuild your exact environment and reproduce your analyses elsewhere. :-)