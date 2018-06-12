# Specify base image
FROM continuumio/anaconda3:latest

# Install packages
# Python packages from conda
RUN conda install -c conda-forge -y \
    jupyterlab \
    nbstripout \
    nodejs 


# Conda supports delegating to pip to install dependencies
# that aren’t available in anaconda or need to be compiled
# for other reasons. 
# RUN pip install -y \

# Create a home for the mounted volume for Jupyter
RUN /bin/bash -c "mkdir /opt/projects"
RUN /bin/bash -c "mkdir /opt/user-settings"

# Set the ENTRYPOINT to use bash
# ENTRYPOINT [ “/bin/bash”, “-c” ]

# Set up environment
EXPOSE 8888

ENV PROJECT_DIR=/opt/projects \
    NOTEBOOK_PORT=8888 \
    SSL_CERT_PEM=/root/.jupyter/jupyter.pem \
    SSL_CERT_KEY=/root/.jupyter/jupyter.key \
    PW_HASH="u'sha1:31cb67870a35:1a2321318481f00b0efdf3d1f71af523d3ffc505'" \
    CONFIG_PATH=/root/.jupyter/jupyter_notebook_config.py \
    SHELL=/bin/bash \
    JUPYTERLAB_SETTINGS_DIR=/opt/user-settings

# Use the environment.yml to create the conda environment.
# ADD environment.yml /tmp/environment.yml
# WORKDIR /tmp
# RUN [ “conda”, “env”, “create” ]

# ADD . /code

# # Use bash to source our new environment for setting up
# # private dependencies—note that /bin/bash is called in
# # exec mode directly
# WORKDIR /code/shared
# RUN [ “/bin/bash”, “-c”, “source activate your-environment && python setup.py develop” ]

# WORKDIR /code
# RUN [ “/bin/bash”, “-c”, “source activate your-environment && python setup.py develop” ]

# # We set ENTRYPOINT, so while we still use exec mode, we don’t
# # explicitly call /bin/bash
# CMD [ “source activate your-environment && exec python application.py” ]

# Copy in the startup script
ADD ./etc/docker_cmd.sh /
# Execute dos to linux in case the script was molested by windows
RUN sed -i -e 's/\r$//' /docker_cmd.sh

# Launch Jupyter lab
WORKDIR ${PROJECT_DIR}
CMD /docker_cmd.sh