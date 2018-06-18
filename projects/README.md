# Projects-README

Clone projects to this directory.  

* All projects will be mounted in the container.
* A conda environment will be created for each project with `environment.yml` in the root of the project

## [Symlinks on Windows with Git Bash](https://www.joshkel.com/2018/01/18/symlinks-in-windows/)

1. Grant permissions to user to [create symlinks](https://github.com/git-for-windows/git/wiki/Symbolic-Links#allowing-non-administrators-to-create-symbolic-links)  
1. Add environemnt variable MSYS=winsymlinks:nativestrict  
1. Set core.symlinks to true see [this link.](https://stackoverflow.com/questions/32847697/windows-specific-git-configuration-settings-where-are-they-set/32849199#32849199)  


## Don't forget to create an environemnt file

Creating an environment file allows one to rebuild the container and install packages automatically.  
From a shell in the container or from the Jupyter lab terminal, run  

```bash  
# Substitute your environment's name for <myenvironment>
source activate <myenvironment>

# Substitute your project's directory for <myproject>
conda env export > /opt/projects/<myproject>/>environment.yml  
```