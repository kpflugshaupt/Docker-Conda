# Installation
Download or clone this repo to your local machine.

Clone or copy any existing work into the `/projects` folder.  

## Using Anaconda in a docker container

1. Install [docker](https://docs.docker.com/)  
1. `Makefile` provides useful commands in the format `make <command>`  
    * Open a shell in the root of this repo  
    * Run `make build` to build the app  
    * If make is not installed on your machine, you can run each command mannualy with copy/paste from the Makefile to your shell. EG to build run `docker build -t pittvax/anaconda .`  
    * Note that running `build` in any form will overwrite your container. Be sure to generate an environment file as described below to rebuild your environment.  
1. Run `make jupyter` to start Jupyter lab.  
    * This will not overwrite your container.  
1. Open https://localhost:8888 to view Jupyter lab  
    * The password is "jupyter" (without the quotes)
    * The big scary warning from your browser about https is normal. You are creating a  self-signed key when you build the container. Self-signed keys make browsers mad. You can safely ignore the warning because you are in control of the Jupyter server and the client which are both on your localhost network. [Read more here.](http://jupyter-notebook.readthedocs.io/en/latest/public_server.html#using-ssl-for-encrypted-communication)
1. To install packages in the container, use the Jupyter lab terminal or open a new local terminal and run `make shell` to open a shell in the container.
1. Shut down the Jupyter server with `ctrl+c` or just close the shell that launched the server.  

## Creating an environment file  
Creating an environment file allows one to rebuild the container and install packages automatically.  

## Usage



## Examples
#TODO
