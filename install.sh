#!/bin/sh

# -e: exit on error
# -u: exit on unset variables
set -eu

# 1. Upgrade packages (for Debian/Ubuntu-based images)
export DEBIAN_FRONTEND=noninteractive
apt-get update && apt-get upgrade -y

# 2. Install helpers
apt-get install -y zsh curl git nano

# 3. Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# 4. Set Zsh as the default shell for the container user
chsh -s $(which zsh) "$(whoami)"

# 5. Install and init chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /usr/local/bin
chezmoi init --apply
