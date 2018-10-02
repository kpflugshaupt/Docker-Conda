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

    # add notebook output strip filter
    echo "
    def scrub_output_pre_save(model, **kwargs):
    """scrub output before saving notebooks"""
        # only run on notebooks
        if model['type'] != 'notebook':
            return
        # only run on nbformat v4
        if model['content']['nbformat'] != 4:
            return

        for cell in model['content']['cells']:
            if cell['cell_type'] != 'code':
                continue
            cell['outputs'] = []
            cell['execution_count'] = None
    c.FileContentsManager.pre_save_hook = scrub_output_pre_save
    
    import io
    import os
    from notebook.utils import to_api_path

    _script_exporter = None

    def script_post_save(model, os_path, contents_manager, **kwargs):
        """convert notebooks to Python script after save with nbconvert

        replaces `jupyter notebook --script`
        """
        from nbconvert.exporters.script import ScriptExporter

        if model['type'] != 'notebook':
            return

        global _script_exporter

        if _script_exporter is None:
            _script_exporter = ScriptExporter(parent=contents_manager)

        log = contents_manager.log

        base, ext = os.path.splitext(os_path)
        script, resources = _script_exporter.from_filename(os_path)
        script_fname = base + resources.get('output_extension', '.txt')
        log.info("Saving script /%s", to_api_path(script_fname, contents_manager.root_dir))

        with io.open(script_fname, 'w', encoding='utf-8') as f:
            f.write(script)

    c.FileContentsManager.post_save_hook = script_post_save
    " >> ${CONFIG_PATH}

    # import os
    # from subprocess import check_call
    # def post_save(model, os_path, contents_manager):
    #     if model['type'] != 'notebook':
    #         return # only do this for notebooks
    #     d, fname = os.path.split(os_path)
    #     check_call(['ipython', 'nbconvert', '--to', 'script', fname], cwd=d)
    # c.FileContentsManager.post_save_hook = post_save

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
    conda env update --file $file -n $name
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