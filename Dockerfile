# Specify base image
FROM continuumio/miniconda3:latest

# Install packages
# Python packages from conda
RUN conda install -c conda-forge -y \
    jupyterlab \
    nbstripout \
    nodejs \
    ipykernel \
    nb_conda \
    nb_conda_kernels 
    
# Conda supports delegating to pip to install dependencies
# that aren’t available in anaconda or need to be compiled
# for other reasons. 
# RUN pip install -y \

# Set up environment
EXPOSE 8888
# Create a home for the mounted volume for Jupyter
RUN /bin/bash -c "mkdir /opt/projects"
RUN /bin/bash -c "mkdir /opt/user-settings"

ENV PROJECT_DIR=/opt/projects \
    NOTEBOOK_PORT=8888 \
    SSL_CERT_PEM=/root/.jupyter/jupyter.pem \
    SSL_CERT_KEY=/root/.jupyter/jupyter.key \
    PW_HASH="u'sha1:31cb67870a35:1a2321318481f00b0efdf3d1f71af523d3ffc505'" \
    CONFIG_PATH=/root/.jupyter/jupyter_notebook_config.py \
    SHELL=/bin/bash \
    JUPYTERLAB_SETTINGS_DIR=/opt/user-settings

# Add build scripts and execute dos to linux in case the script was molested by windows
RUN /bin/bash -c "mkdir /opt/etc"
ADD etc/docker_cmd.sh /opt/etc/docker_cmd.sh
RUN sed -i -e 's/\r$//' /opt/etc/docker_cmd.sh
RUN /bin/bash -c "chmod +x /opt/etc/docker_cmd.sh"
ADD etc/base-environment.yml /opt/etc/base-environment.yml
RUN sed -i -e 's/\r$//' /opt/etc/base-environment.yml

# Launch Jupyter lab
WORKDIR ${PROJECT_DIR}
CMD  /opt/etc/docker_cmd.sh