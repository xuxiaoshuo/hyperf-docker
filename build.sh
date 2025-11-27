#!/usr/bin/env bash

set -e

# determine swoole version to build.
TASK=${1}
CHECK=${!#}

function check_or_push() {
    TAG=${1}
    if [[ ${CHECK} == "--check" ]]; then
        echo "Checking $TAG ..."
        version=`docker run 550419038/hyperf:$TAG php -v`
        echo $version | grep -Eo "PHP \d+\.\d+\.\d+"
        swoole=`docker run 550419038/hyperf:$TAG php --ri swoole` && echo $swoole | grep -Eo "Version => \d+\.\d+\.\d+" || echo "No Swoole."
    fi

    if [[ ${CHECK} != "--check" ]]; then
        echo "Publishing "$TAG" ..."
        # Push origin image
        docker push 550419038/hyperf:${TAG}
    fi

    echo -e "\n"
}

# build base image
if [[ ${TASK} == "build" ]]; then
    # PHP 8.1
    export PHP_VERSION=8.1
    for ALPINE_VERSION in 3.16 3.17 3.18 3.19; do
        export ALPINE_VERSION
        docker-compose build alpine-base
    done

    # PHP 8.2
    export PHP_VERSION=8.2
    for ALPINE_VERSION in 3.18 3.19 3.20 3.21 3.22; do
        export ALPINE_VERSION
        docker-compose build alpine-base
    done

    # PHP 8.3
    export PHP_VERSION=8.3
    for ALPINE_VERSION in 3.19 3.20 3.21 3.22 edge; do
        export ALPINE_VERSION
        docker-compose build alpine-base
    done

    # PHP 8.4
    export PHP_VERSION=8.4
    for ALPINE_VERSION in 3.21 3.22 edge; do
        export ALPINE_VERSION
        docker-compose build alpine-base
    done
fi

if [[ ${TASK} == "publish" ]]; then
    # Push base image
    TAGS=""

    # PHP 8.1
    for AV in 3.16 3.17 3.18 3.19; do TAGS="$TAGS 8.1-alpine-v$AV-base"; done
    # PHP 8.2
    for AV in 3.18 3.19 3.20 3.21 3.22; do TAGS="$TAGS 8.2-alpine-v$AV-base"; done
    # PHP 8.3
    for AV in 3.19 3.20 3.21 3.22 edge; do TAGS="$TAGS 8.3-alpine-v$AV-base"; done
    # PHP 8.4
    for AV in 3.21 3.22 edge; do TAGS="$TAGS 8.4-alpine-v$AV-base"; done

    for TAG in ${TAGS}; do
        check_or_push $TAG
    done
fi
