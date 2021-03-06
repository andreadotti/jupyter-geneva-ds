#!/usr/bin/env bash
image_name="andreadotti/jupyter-geneva-ds"
container_name="myjupyter"
keepcontainerafteruse=0
sharecurrenworkdir=0
maxwaittime=10
pullimage=0

usage() { 
  echo "Usage: $0 [-i <image_name>] [-c <container_name> ] [-k] [-s] [-t N] [-p] [-h]" 1>&2
  echo "  Where: " 1>&2
  echo "    -i <image_name> : specify the docker container image name to use (default ${image_name})" 1>&2
  echo "    -c <container_name> : specify the docker container name to use (default ${container_name})" 1>&2
  echo "    -k : instruct doker to keep the container instance after use (default remove). Note that image is not removed, only container instance" 1>&2
  echo "    -s : share with container instance the current directory in read-write mode" 1>&2
  echo "    -t <N> : specify timeout operations (default 10 s)" 1>&2
  echo "    -p : pull/update docker container image" 1>&2
  echo "    -h : show this help" 1>&2
  echo "  See: https://github.com/andreadotti/jupyter-geneva-ds for additional information" 1>&2

}

while getopts "i:c:kst:ph" o; do
    case "${o}" in
        i)
            image_name="${OPTARG}"
            ;;
        c)
            container_name="${OPTARG}"
            ;;
        k)
            keepcontainerafteruse=1
            ;;
        s)
            sharecurrenworkdir=1
            ;;
        t)
            maxwaittime=${OPTARG}
            ;;
        p)
            pullimage=1
            ;;
	h)
	    usage
	    exit 0
	    ;;
        *)
            usage
	    exit 1
            ;;
    esac
done
shift $((OPTIND-1))

thisdir=`pwd`
dockerparams="-d -it -p 8888:8888 --name ${container_name} -w /home/jovyan/work"
[ $keepcontainerafteruse -eq 0 ] && dockerparams=$dockerparams" --rm"
[ $sharecurrenworkdir -eq 1 ] && dockerparams=$dockerparams" -v ${thisdir}:/home/jovyan/work:rw"

[ $pullimage -eq 1 ] && docker pull $image_name

echo "Starting docker container named ${container_name} with id:"
docker run $dockerparams $image_name
sleep 1s

msg=`docker container ls | grep ${container_name}`
ctr=0
while [ $ctr -le $maxwaittime ] && [ X"${msg}" == X ];do
    ctr=$((ctr+1))
    msg=`docker container ls | grep ${container_name}`
    sleep 1s
done 

if [ $ctr -ge $maxwaittime ];then
    echo "Timeout (${maxwaittime} s), container did not start"
    exit 1
fi

addrraw=`docker container logs ${container_name} | grep -E '^\s+http'`
#There is the possibility I arrive here and the container did not arrive yet to write the output,
ctr=0
while [ $ctr -le $maxwaittime ] && [ X"${addrraw}" == X ];do
    ctr=$((ctr+1))
    addrraw=`docker container logs ${container_name} | grep -E '^\s+http'`
    sleep 1s
done

if [ $ctr -ge $maxwaittime ];then
    echo "Error, container output is not correct, maybe container did not start correctly maybe container did not start correctly (check that webaddress is present with 'docker container logs ${container_name})?"
    exit 1
fi

echo "The jupyter instance can be reached at:"
#warning webaddress can be of the format: http://(xxxxxx or 127.0.0.1):8888/?token=.......
#Need to parse it to extract the IP address and remove what is not needed
echo $addrraw  | sed 's/^\(http[s]*:\/\/\)[([a-z0-9]* or ]*\([0-9.]*\)[)]*:\(.*\)/\1\2:\3/'
#match=`echo $addrraw | cut -d: -f2 | cut -d' ' -f3 | sed 's/)//g'`
