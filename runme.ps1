<#
.SYNOPSIS
Start execution of SYNTHETICA datascience notebook. 
.DESCRIPTION
This executes SYNTEHTICA datascience jupyter python notebook 
in a docker container.
Run the script without argument to use provided notebooks, 
warning: changes will be lost after the container is run.
The first time the script is run, it is recomended to add 
parameter -PullImage to download the image.
.PARAMETER ImageName
The name of the image to use, default "mytest"
.PARAMETER ContainerName
The name to gibe to the container, default "myjupyter"
.PARAMETER KeepContainerAfterUse
If set keep container, otherwise add --rm to docker run
.PARAMETER ShareCurrentWorkDir
If set use directory from where script is run as docker volume and overwrite
default content
.PARAMETER MaxWaitTime
Maximum time (in s) to wait for container to start
.PARAMETER PullImage
Update the container image from hub
.EXAMPLE
First time use:
    runme.ps1 -PullImage
Share current workarea and replace provided notebooks:
    runme.ps1 -ShareCurrentWorkDir
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)][string]$ImageName="mytest",
    [Parameter(Mandatory=$false)][string]$ContainerName="myjupyter",
    [Parameter(Mandatory=$false)][switch]$KeepContainerAfterUse,
    [Parameter(Mandatory=$false)][switch]$ShareCurrentWorkDir,
    [Parameter(Mandatory=$false)][int16]$MaxWaitTime=10,
    [Parameter(Mandatory=$false)][switch]$PullImage
        
    )
$pwd=(Convert-Path .)
Write-Debug "Current Directory is: $pwd"
Write-Debug "Image name: $ImageName"
# In linux change user id and add it to the users group w/ --user $(id -u):$(id -g) --add-group users
# See: https://stackoverflow.com/questions/51120204/docker-how-to-handle-permissions-for-jupyter-notebook-3-approaches-that-do-not

#Define an array of parameters
$DockerParams=@(
    "-d"
    "-it",
    "-p", "8888:8888",
    "--name","$ContainerName",
    "-w","/home/jovyan/work"
    )
If ($KeepContainerAfterUse -eq $false) { $DockerParams=$DockerParams+"--rm" }
If ($ShareCurrentWorkDir) {$DockerParams=$DockerParams+"-v"+"${pwd}:/home/jovyan/work"}

If ($PullImage) {
    Write-Debug "Pull container image"
    docker pull $ImageName
}

#The &,@ is used because of the array use
Write-Debug "Parameters for docker run are: $DockerParams"
Write-Output "Starting docker container named ""$ContainerName"" with id:"
& docker.exe run @DockerParams $ImageName 
Start-Sleep -s 1
# Wait for container to start....
#Check a container with given name exists matching output of docker command that must be > 0 in length as string
$ctr=0
while ($(docker.exe container ls | Select-String ".*${ContainerName}$" | Out-String).Length -eq 0 -AND $ctr -le $MaxWaitTime) { 
    Write-Debug "Container is not alive, waiting for container to start..."
    Start-Sleep -s 1
    $ctr=$ctr+1
}
If ($ctr -ge $MaxWaitTime) {
    Write-Error "Timeout ($MaxWaitTime s), container did not start"
    exit 2
}

Write-Debug "Container started, ready to go $(docker container logs ${ContainerName})" | Out-String

#Container has started from STDOUT get the string that indicates webpage and token to open
#warning webaddress can be of the format: http://(xxxxxx or 127.0.0.1):8888/?token=.......
#Need to parse it to extract the IP address and remove what is not needed
$addrraw=$(docker container logs $ContainerName | Select-String '^\s+http://.*' | Out-String).Trim()
#                                     1                2              3         4
$match=[regex]::Match($addrraw,'^(http[s]?://)\(?([a-z0-9]+\sor\s)?([0-9\.]+)\)?(:.*)')
Start-Process -FilePath $($match.Groups[1].Value+$match.Groups[3].Value+$match.Groups[4].Value | Out-String)
Write-Output "The jupyter instance can be reached at:"
Write-Output $($match.Groups[1].Value+$match.Groups[3].Value+$match.Groups[4].Value | Out-String)
