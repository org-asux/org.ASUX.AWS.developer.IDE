#!/bin/bash -f

echo "Does not work to upgrade to AWS-CLI v2."
echo ''
echo "But has commands to use HOMEBREW on linux .. if you ever need to .."
exit 1

### @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

# Change to default Python3
python3 --version
python() {
    python3 $@
}

python --version

# Install Code Formatter for Python and you need to set AWS Cloud9「Preferences」->「Python Support」->「Custom Code Formatter」
# yapf -i "$file"
echo ''; read -p "Upgrading AWS CLI via YUM .. Ok? >>" ANS
# sudo pip install yapf
# sudo yum -y update
# sudo yum -y install aws-cli
# sudo -H pip install awscli --upgrade

# Install brew and update SAM CLI to the latest version.
echo ''; read -p "Installing HomeBrew on LINUX .. Ok?>>" ANS

sudo ln -s /bin/touch /usr/bin/touch
yes | sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
test -d ~/.linuxbrew && eval $(~/.linuxbrew/bin/brew shellenv)
test -d /home/linuxbrew/.linuxbrew && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
test -r ~/.bash_profile && echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>~/.bash_profile

echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>~/.profile

brew --version
brew tap aws/tap

echo ''; read -p "Installing SAM-CLI .. Ok? >>" ANS
brew install aws-sam-cli

echo ''
sam --version

### EoScript

