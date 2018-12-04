# Docker image for datascience

This is a customiyation of the official `jupyter/scipy-notebook` image with additional
packages and configurations. 

# Running the image

## USe automatic script

TODO 

## Manually run docker instance

Assuming you want to create/modify notebooks in the host directory `myhostdirectory`
The image can be run manually with:

```bash
$ cd myhostdirectory
$ docker run -ti -p 8888:8888 -v myhostdirectory:/home/jovyan/work <this-image-or-derived>
```
Then open the webpage 

On Linux/Mac it may be useful to set the user and group ids so that ownership 
of files between docker container and host is preserved:

```bash
```


# Adding and modifying packages or configurations

A pythong package can be added modifying the `environment.yml` file.  
A post install script `post-install.sh` is run after installing the python packages, provide additional configuration/installation steps in this script.

## List of installed software

Build and run the image, the list of available packages will be appended to this README file.