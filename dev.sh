#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

NVIM_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
REPO_DIR="$(pwd)"
BACKUP_DIR="$REPO_DIR/backup"


if ! [ -L "$NVIM_CONFIG_DIR" ]; then
  mkdir -p "$BACKUP_DIR"
  mv "$NVIM_CONFIG_DIR" "$BACKUP_DIR"
  echo "Moved $NVIM_CONFIG_DIR to $BACKUP_DIR"
fi

echo "Linking $REPO_DIR to $NVIM_CONFIG_DIR"
rm -rf "$NVIM_CONFIG_DIR"
ln -s "$REPO_DIR" ~/.config/nvim
