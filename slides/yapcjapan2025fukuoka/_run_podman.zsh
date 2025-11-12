#!/bin/zsh

set -e

cd $0:h

podman run -it --rm -v $PWD:/app:Z -w /app ubuntu:latest bash
