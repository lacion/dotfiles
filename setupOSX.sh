function install_xcode_cli {
  echo "Installing Xcode CLI tools..."
  xcode-select --install
}

function install_brew {
  echo "Installing Homebrew..."
  if !(hash brew 2>/dev/null); then
    ruby \
    -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" \
    </dev/null
    brew doctor
  else
    echo "Brew was already installed, upgrading"
    brew update
    brew upgrade
  fi
}

function install_brew_cask {
  echo "Installing Homebrew Cask..."
  brew cask > /dev/null 2>&1;
  if [ $? -ne 0 ]; then
    brew tap homebrew/cask
    brew doctor
  else
    echo "Brew cask was already installed, upgrading"
    brew update
    brew upgrade
  fi
  brew tap homebrew/cask-versions
  brew tap homebrew/cask-drivers
  brew tap homebrew/cask-fonts  
  brew tap fishtown-analytics/dbt
}

function setup_brew {
  echo "Setting up brew..."
  install_brew
  install_brew_cask
}

function install_brew_deps {
  echo "Installing brew dependencies..."
  cat OSX/brew-requirements.txt | xargs brew install
  brew cleanup
  brew doctor
}

function install_brew_cask_deps {
  echo "Installing brew cask dependencies..."
  cat OSX/cask-requirements.txt | xargs brew install --force
  brew cleanup
  brew doctor
}

function install_npm_globals {
  echo "Installing npm globals... using yarn."
  if hash yarn 2>/dev/null; then
  	cat OSX/npm-global-requirements.txt | xargs sudo yarn global add
  fi
}

function install_python_globals {
  echo "Installing python globals..."
  cat OSX/python-global-requirements.txt | xargs sudo easy_install
}

function install_dotfiles {
  echo "Installing dotfiles"
  # Copy boilerplate bash profile and init settings
  test -f ~/.zshrc || `cp zshrc ~/.zshrc && source ~/.zshrc`
  cd $ZSH_CUSTOM/plugins && git clone https://github.com/chrissicool/zsh-256color && cd
  rm -rf ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
}

function setup_mac {
echo "---> Enable full keyboard access for all controls (e.g. enable Tab in modal dialogs)"
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3 2>/dev/null

echo "---> Set a blazingly fast trackpad speed"
defaults write -g com.apple.trackpad.scaling -int 5 2>/dev/null

echo "---> Automatically illuminate built-in MacBook keyboard in low light"
defaults write com.apple.BezelServices kDim -bool true 2>/dev/null

echo "---> Turn off keyboard illumination when computer is not used for 5 minutes"
defaults write com.apple.BezelServices kDimTime -int 300 2>/dev/null

echo "---> Disable the warning when changing a file extension"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false 2>/dev/null

}

#Manually copy needed files such as ssh if present
echo "---> Ask for the administrator password upfront"
sudo -v

# Keep-alive: update existing `sudo` time stamp until finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

setup_mac
install_dotfiles
install_xcode_cli
setup_brew
install_brew_cask_deps
install_brew_deps
install_npm_globals
install_python_globals