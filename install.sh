#!/bin/sh

# -e: exit on error
# -u: exit on unset variables
set -eu

# 1. Upgrade packages (for Debian/Ubuntu-based images)
export DEBIAN_FRONTEND=noninteractive
apt-get update && apt-get upgrade -y

# 2. Install Zsh
apt-get install -y zsh curl git

# 3. Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# 4. Set Zsh as the default shell for the container user
chsh -s $(which zsh) "$(whoami)"

# Enable and persist Zsh history
mkdir /workspace
touch /workspace/.zsh_history
chmod 600 /workspace/.zsh_history

# 5. Install chezmoi if not already installed
if [ ! -x "$(command -v chezmoi)" ]; then
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /usr/local/bin
fi

chezmoi init --apply --source=$PWD
