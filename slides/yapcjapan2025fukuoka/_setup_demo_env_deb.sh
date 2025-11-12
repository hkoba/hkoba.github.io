#!/bin/sh

# podman run -it --rm ubuntu:latest bash

set -e

apt update

apt install -y perl curl zsh gcc make

curl -fsSL https://raw.githubusercontent.com/skaji/cpm/main/cpm > cpm

chmod +x ./cpm

./cpm install -g MouseX::OO_Modulino App::oo_modulino_zsh_completion_helper File::AddInc

zsh
