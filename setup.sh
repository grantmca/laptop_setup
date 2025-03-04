#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo_color() {
  color=$1
  message=$2
  echo -e "${color}${message}${NC}"
}

cd ~

if ! command -v brew &> /dev/null; then
  echo_color $YELLOW "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo_color $GREEN "Homebrew is already installed"
fi

echo_color $YELLOW "Updating Homebrew..."
brew update

echo_color $YELLOW "Installing command line tools..."
cli_tools=(
ipython
ansible
git
curl
tree
htop
jq
neovim
zk
node
rbenv
pyenv
pyright
postgresql@14
mysql@8.0
node
npm
yabai
tmux
luarocks
bat
dnsmasq
eslint
fzf
lua
skhd
luajit
neofetch
redis
yazi
stow
bitwarden-cli
)

for tool in "${cli_tools[@]}"; do
  if brew list $tool &>/dev/null; then
    echo_color $GREEN "$tool is already installed"
  else
    echo_color $YELLOW "Installing $tool..."
    brew install $tool
  fi
done

# Install applications using Homebrew Cask
echo_color $YELLOW "Installing applications..."
apps=(
docker
google-chrome
visual-studio-code
firefox
spotify
slack
ghostty
aws-cli
bitwarden
chromedriver
gimp
obs
microsoft-outlook
libreoffice
font-fira-code-nerd-font
datagrip
cyberduck
chromium
)

for app in "${apps[@]}"; do
  if brew list --cask $app &>/dev/null; then
    echo_color $GREEN "$app is already installed"
  else
    echo_color $YELLOW "Installing $app..."
    brew install --cask $app
  fi
done

# Make Developer Dir
mkdir Developer

echo_color $YELLOW "Configuring Mac settings..."

defaults write com.apple.finder AppleShowAllFiles YES

defaults write com.apple.finder ShowPathbar -bool true

defaults write com.apple.finder ShowStatusBar -bool true

defaults write com.apple.menuextra.battery ShowPercent -bool true

# Restart affected applications
echo_color $YELLOW "Restarting affected applications..."
killall Finder
killall SystemUIServer

# Clean up
echo_color $YELLOW "Cleaning up..."
brew cleanup


# Clone dotfiles
git clone https://github.com/grantmca/.dotfiles.git

cd .dotfiles

configs=(
ghostty
htop
nvim
github-copilot
ssh
skhd
task
tmux
yabai
zsh
zk
wezterm
)

for config in "${configs[@]}"; do
  echo_color $YELLOW "Configuring $config..."
  stow $config
done

cd ~

# Install Zap

zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1

# Decrypt some of our files

encrypted_files=(
~/.dotfiles/github-copilot/.config/github-copilot/hosts.json
~/.dotfiles/ssh/.ssh/id_rsa
~/.dotfiles/ssh/.ssh/id_rsa.pub
~/.dotfiles/task/.taskrc
~/.dotfiles/zsh/.config/zsh/zsh-keys
)

ansible-vault decrypt "${encrypted_files[@]}" 2>/dev/null || true

echo_color $GREEN "Setup complete! Some changes may require a system restart to take effect."
