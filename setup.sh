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

confirm() {
  local prompt="$1"
  read -r -p "$prompt (y/N): " response
  case "$response" in
    [yY]|[yY][eE][sS])
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

cd ~

if xcode-select --print-path &>/dev/null; then
  echo "Apple Command Line Tools are already installed."
else
  echo "Installing Apple Command Line Tools..."
  xcode-select --install
fi

if ! command -v brew &> /dev/null; then
  echo_color $YELLOW "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  export PATH="/opt/homebrew/bin:$PATH"
else
  echo_color $GREEN "Homebrew is already installed"
fi

if ! command -v brew &> /dev/null; then
  return 1
fi

echo_color $YELLOW "Updating Homebrew..."
brew update

echo_color $YELLOW "Installing command line tools..."
cli_tools=(
  taskwarrior-tui
  task
  pnpm
  imagemagick
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
  solargraph
  pyenv
  pyright
  postgresql@14
  mysql@8.0
  node
  npm
  koekeishiya/formulae/yabai
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
  # google-chrome
  visual-studio-code
  # firefox
  spotify
  # slack
  zoom
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
git config user.name "Grant McAllister"
git config user.name "grantmca2221@gmail.com"
cd ~

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
  cd ~/.dotfiles
  echo_color $YELLOW "Configuring $config..."
  stow $config
done

# Install plugin manager
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

cd ~

# Install Zap

if ! command -v zap &> /dev/null; then
  echo_color $YELLOW "Installing Zap..."
  zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1
  export PATH="/opt/homebrew/bin:$PATH"
else
  echo_color $GREEN "Homebrew is already installed"
fi

# Decrypt some of our files

encrypted_files=(
  ~/.dotfiles/github-copilot/.config/github-copilot/hosts.json
  ~/.dotfiles/ssh/.ssh/id_rsa
  ~/.dotfiles/ssh/.ssh/id_rsa.pub
  ~/.dotfiles/task/.taskrc
  ~/.dotfiles/zsh/.config/zsh/zsh-keys
)

ansible-vault decrypt "${encrypted_files[@]}" 2>/dev/null || true

git clone git@github.com:grantmca/notebook.git

magick -size 1920x1080 xc:"#1a1b26" $HOME/Pictures/tokyo-night-storm.png

osascript <<EOF
tell application "System Events"
  set allDesktops to a reference to every desktop
  repeat with d in allDesktops
    set picture of d to (POSIX file "$HOME/Pictures/tokyo-night-storm.png") as text
  end repeat
end tell
EOF
killall Dock

# Restart Service
yabai --start-service
skhd --start-service

# Install plugins

export BROWSER="firefox"

if confirm "Have you installed Bitwarden Plugin to Firefox?"; then
  echo "Great, moving forward..."
else
  open "https://addons.mozilla.org/en-US/firefox/addon/bitwarden-password-manager/"
  echo "Please complete the required setup."
fi

if confirm "Have you installed vimimum to Firefox?"; then
  echo "Great, moving forward..."
else
  open "https://addons.mozilla.org/en-US/firefox/addon/vimium-ff/"
  echo "Please complete the required setup."
fi

if confirm "Have you installed Multi-Account Container?"; then
  echo "Great, moving forward..."
else
  open "https://addons.mozilla.org/en-US/firefox/addon/multi-account-containers/"
  echo "Please complete the required setup."
fi

if confirm "Have you installed AXE Devtools?"; then
  echo "Great, moving forward..."
else
  open "https://addons.mozilla.org/en-US/firefox/addon/axe-devtools/"
  echo "Please complete the required setup."
fi

if confirm "Have you given mac yabai permission?"; then
  echo "Great, moving forward..."
else
  echo "Please complete the required setup."
fi

if confirm "Have you given mac skhd permission?"; then
  echo "Great, moving forward..."
else
  echo "Please complete the required setup."
fi

if confirm "Have you set the app bar to small and hide when not in use?"; then
  echo "Great, moving forward..."
else
  echo "Please complete the required setup."
fi

if confirm "Have you set caps lock to ctrl?"; then
  echo "Great, moving forward..."
else
  echo "Please complete the required setup."
fi

if confirm "Have you installed tmux tmp using ctrl a I?"; then
  echo "Great, moving forward..."
else
  echo "Please complete the required setup."
fi

if confirm "Have you update the ctrl+shift+S?"; then
  echo "Great, moving forward..."
else
  echo "Open System Settings (or System Preferences on older macOS versions).\nGo to Accessibility.\nScroll down and select Spoken Content.\nToggle on Speak selection.\nClick Options… to adjust the speaking voice and rate."
  echo "Please complete the required setup."
fi


echo_color $GREEN "Setup complete! Some changes may require a system restart to take effect."
