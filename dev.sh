#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

NVIM_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
REPO_DIR="$(pwd)"


echo "Linking $REPO_DIR to $NVIM_CONFIG_DIR"
rm -rf "$NVIM_CONFIG_DIR"
ln -s "$REPO_DIR"/nvim/~/.config/nvim
