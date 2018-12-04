# Docker image for data-science

This is a customization of the docker `jupyter/scipy-notebook` image with additional
packages and configurations. 

# Running the image

The container can be run with an helper script or manually.

## Use helper scripts

### Windows 10 

Open a PowerShell prompt and use `runme.ps1` script.  
Get help with: `Get-Help .\runme.ps1`.

### Linux/Mac OS X

TODO

## Run without helper scripts

Assuming you want to share the host directory `<myhostdirectory>`.
The image can be run manually with:

```bash
$ docker run -ti -p 8888:8888 -v <myhostdirectory>:/home/jovyan/work <imagename>
```
Then open the webpage.

On Linux/Mac it may be useful to set the user and group ids so that ownership 
of files between docker container and host is preserved:

```bash
$ docker run -ti --user $(id -u):$(id -g) --add-group users \ 
         -p 8888:8888 -v <myhostdirectory>:/home/jovyan/work \ 
        <imagename>
```

**Important Notes**:

 * Differently from the use of the helper scripts, the change to the working directory `/home/jovyan/work` is not performed automatically.  
 * It is recommended **not** to share the host directory with a sub-directory of the container home to avoid interference of the host directory with the container environment.

# Creating a derived image

TODO

# Adding and modifying packages or configurations

A python package can be added modifying the `environment.yml` file.  
A post install script `post-install.sh` is run after installing the python packages, provide additional configuration/installation steps in this script.

## List of installed software

Build and run the image, the list of available packages will be appended to this README file.