# Specify base image
FROM continuumio/anaconda3:latest

# Set the ENTRYPOINT to use bash
# ENTRYPOINT [ “/bin/bash”, “-c” ]

# Install packages
# Python packages from conda
RUN conda install -c conda-forge -y \
    jupyterlab \
    nbstripout \
    nodejs \
    ipykernel \
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

# Use the environment.yml to create the conda environment.

# RUN /bin/bash -c "conda env create -n environment"
ADD environment.yml /tmp/environment.yml
# WORKDIR /tmp
# ENTRYPOINT [ “/bin/bash”, “-c” ]
# RUN [ “conda”, “env”, “create” ]

# # We set ENTRYPOINT, so while we still use exec mode, we don’t
# # explicitly call /bin/bash
# CMD [ “source activate your-environment && exec python application.py” ]

# Copy in the startup script
WORKDIR /
ADD ./etc/docker_cmd.sh /
# Execute dos to linux in case the script was molested by windows
RUN sed -i -e 's/\r$//' /docker_cmd.sh
RUN /bin/bash -c "chmod +x /docker_cmd.sh"

# Launch Jupyter lab
WORKDIR ${PROJECT_DIR}
# CMD "conda create --name docker-conda && conda activate docker-conda"
CMD  /docker_cmd.sh
# RUN [ “/bin/bash”, “-c”, “source activate docker-conda” ]
