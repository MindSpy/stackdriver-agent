#!/bin/bash

env_file=env.hcl
BUILDER_NAME=multiarch
BAKE_ARGS=""
default_platform=linux/amd64
force_push=0
for arg in "$@"; do
  case "$arg" in
    --env=*) 
        env_file="${arg#*=}"
        ;;
    --builder=*) 
        BUILDER_NAME="${arg#*=}"
        ;;
    --targets=*) 
        targets="${arg#*=}"
        ;;
    --platform=*)
        platform="${arg#*=}"
        ;;
    --push)
        force_push=1
        ;;
    --print | --load)
        BAKE_ARGS="$BAKE_ARGS $arg"
        ;;
    *)
        test "${arg}" != "--help" -a "${arg}" != "-h"  && printf "ERROR: unexpected argument: \"$arg\"\n"
        printf "\nUsage: $(basename $0) [OPTS]\n"
        printf "\nwhere [OPTS] can be:\n"
        printf "\t--env=[env file]  -  name of env file to source, default: env.hcl\n"
        printf "\t--builder=[name]  - name of builder to create (if not exists) and use, default: multiarch\n"
        printf "\t--targets=[list of targets]  - list of targets to build\n\n"
        printf "\tNote: In case the local git contains changes only a \"dev\" target is built\n"
        printf "\t      for a single arch \"linux/386\" with docker image tag of \"dev-DIRTY\".\n"
        exit 
        ;;
    esac
done

# source and export env variables
set -a
test -e $env_file && source $env_file

set -ex

if ! docker buildx ls | grep ^$BUILDER_NAME -c > /dev/null 2>&1; then

    docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
    docker run --privileged --rm tonistiigi/binfmt --install all

    DRIVER_OPTS=""
    if [ -n "${PKG_PROXY_NET}" ]; then
        DRIVER_OPTS="--driver-opt network=${PKG_PROXY_NET}"
    fi

    docker buildx create --name $BUILDER_NAME --use --driver docker-container $DRIVER_OPTS
    docker buildx inspect --bootstrap
fi

# override env variables
BUILD_DATE="$(date +%Y%m%d)"
if [ -n "$(git status -s)" ]; then
  GIT_BRANCH=DIRTY 
else 
  GIT_BRANCH=$(git rev-parse --short HEAD)
fi

if [ "${platform:-${default_platform}}" != "all"  ]; then
  platform_arg="--set *.platform=${platform:-${default_platform}}"
fi

if [ "${force_push}" -eq 0 ] && [ -z "${GIT_BRANCH}" -o "${GIT_BRANCH}" == "DIRTY" ]; then
  if [ -z "$targets" ]
  then targets=dev
   fi
  if [ -z "$progress" ]
  then progress="--progress=plain"
  fi
  if [ -n "$platform_arg" ]; then
    platform_arg="$platform_arg --load"
  fi
  BAKE_ARGS="$BAKE_ARGS $progress $platform_arg $targets"
else
  if [ -n "$platform" ]; then
    BAKE_ARGS="$BAKE_ARGS --set *.platform=${platform}"
  fi
  if [ -z "$platform" ]; then
    unset platform_arg
  fi
  BAKE_ARGS="$BAKE_ARGS --push $progress $platform_arg $targets"
fi

docker buildx bake -f docker-bake.hcl $BAKE_ARGS
