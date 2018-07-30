# Specify base image
FROM continuumio/miniconda3:latest

# Install packages
RUN apt-get update && apt-get install -y dos2unix gcc

# Python packages from conda
RUN conda install -c conda-forge -y \
    jupyterlab \
    nbstripout \
    nodejs \
    ipykernel \
    nb_conda \
    nb_conda_kernels \
    # Update base environment with defaults
    && if [ -f '/opt/etc/base-environment.yml' ]; then \
            conda env update -q --yes -f /opt/etc/base-environment.yml \
        else \
            conda update -q --yes -n base conda \
        fi 
    
    
# Conda supports delegating to pip to install dependencies
# that aren’t available in anaconda or need to be compiled
# for other reasons. 
# RUN pip install -q \

# Set up environment
EXPOSE 8888
# Create a home for the mounted volume for Jupyter
RUN /bin/bash -c "mkdir /opt/projects"
RUN /bin/bash -c "mkdir /opt/user-settings"
RUN /bin/bash -c "mkdir /opt/credentials"

ENV PROJECT_DIR=/opt/projects \
    NOTEBOOK_PORT=8888 \
    SSL_CERT_PEM=/root/.jupyter/jupyter.pem \
    SSL_CERT_KEY=/root/.jupyter/jupyter.key \
    PW_HASH="u'sha1:31cb67870a35:1a2321318481f00b0efdf3d1f71af523d3ffc505'" \
    CONFIG_PATH=/root/.jupyter/jupyter_notebook_config.py \
    SHELL=/bin/bash \
    JUPYTERLAB_SETTINGS_DIR=/opt/user-settings

# Add build scripts and execute dos to linux in case the script was molested by windows
WORKDIR ${PROJECT_DIR}
ADD etc/ /opt/etc/
WORKDIR /opt/etc/
RUN /bin/bash -c "find . -type f -print0 | xargs -0 dos2unix"
RUN /bin/bash -c "chmod +x /opt/etc/docker_cmd.sh"

# Launch Jupyter lab
WORKDIR ${PROJECT_DIR}
CMD ["/bin/bash", "/opt/etc/docker_cmd.sh"]
