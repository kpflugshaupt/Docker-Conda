# !/bin/bash

function parse_yaml {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

# generate configuration, cert, and password if this is the first run
if [ ! -f /var/tmp/pv-conda_init ] ; then
    jupyter notebook --allow-root --generate-config
    if [ ! -f ${SSL_CERT_PEM} ] ; then
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
            -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=127.0.0.1" \
            -keyout ${SSL_CERT_KEY} -out ${SSL_CERT_PEM}
    fi
    echo "c.NotebookApp.password = ${PW_HASH}" >> ${CONFIG_PATH}

    # Update base environment with defaults
    if [ -f '/opt/etc/base-environment.yml' ]; then
        conda env update -q -f /opt/etc/base-environment.yml
    else
        conda update -q -n base conda
    fi

    # create environemts for projects
    for file in $(find /root/projects -name environment.yml); do
    eval $(dos2unix $file)
    eval $(parse_yaml $file)
    source activate base
    conda env create --file $file -n $name
    # install environment kernel in jupyter
    source activate $name
    conda install -c conda-forge ipykernel
    ipython kernel install --name=$name
    done

    # record the first run
    touch /var/tmp/pv-conda_init
fi

jupyter lab --allow-root -y --no-browser --notebook-dir=${PROJECT_DIR} \
    --certfile=${SSL_CERT_PEM} --keyfile=${SSL_CERT_KEY} --ip='*' \
    --config=${CONFIG_PATH}