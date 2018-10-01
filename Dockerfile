# Specify base image
FROM continuumio/miniconda3:latest

# Define environment variables in the container
ENV PROJECT_DIR=/root/projects \
    NOTEBOOK_PORT=8888 \
    SSL_CERT_PEM=/root/.jupyter/jupyter.pem \
    SSL_CERT_KEY=/root/.jupyter/jupyter.key \
    PW_HASH="u'sha1:31cb67870a35:1a2321318481f00b0efdf3d1f71af523d3ffc505'" \
    CONFIG_PATH=/root/.jupyter/jupyter_notebook_config.py \
    SHELL=/bin/bash \
    JUPYTERLAB_SETTINGS_DIR=/root/user-settings

# Add build scripts
ADD etc/ /opt/etc/
WORKDIR /opt/etc/

# Install packages
RUN apt-get update && apt-get install -y dos2unix gcc nano\
    # Python packages from conda
    && conda install -c conda-forge -y \
    jupyterlab \
    nbstripout \
    nodejs \
    ipykernel \
    nb_conda \
    nb_conda_kernels \
    # Create a home for the mounted volumes
    && mkdir /root/user-settings \
    && mkdir /root/credentials \
    # execute dos2unix in case the script was molested by windows
    && find . -type f -print0 | xargs -0 dos2unix \
    # make startup script executable
    && chmod +x /opt/etc/docker_cmd.sh

# Expose port 8888 to host
EXPOSE 8888

# Run additional installation steps in the container
WORKDIR ${PROJECT_DIR}
CMD ["/bin/bash", "/opt/etc/docker_cmd.sh"]
