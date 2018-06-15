#!/bin/bash

#
# generate configuration, cert, and password if this is the first run
#
if [ ! -f /var/tmp/pv-conda_init ] ; then
    jupyter notebook --allow-root --generate-config
    if [ ! -f ${SSL_CERT_PEM} ] ; then
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
            -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=127.0.0.1" \
            -keyout ${SSL_CERT_KEY} -out ${SSL_CERT_PEM}
    fi
    echo "c.NotebookApp.password = ${PW_HASH}" >> ${CONFIG_PATH}
    # update base environment from user provided backup or use default
    if [ -f '/opt/projects/environment.yml' ]; then 
        conda env update -f /opt/projects/environment.yml
    else
        conda env update -f /tmp/environment.yml
    fi
    touch /var/tmp/pv-conda_init
fi

jupyter lab --allow-root -y --no-browser --notebook-dir=${PROJECT_DIR} \
    --certfile=${SSL_CERT_PEM} --keyfile=${SSL_CERT_KEY} --ip='*' \
    --config=${CONFIG_PATH}