#!/bin/sh
#
# This script will set up development environment.
#

# Generates a colored info log message in stdout
info() {
    echo "\033[1;37m>>>\033[0m \033[1;34m$1\033[0m"
}

# Generates a colored ok log message in stdout
ok() {
    echo "\033[1;37m>>>\033[0m \033[1;32m$1\033[0m"
}

# Generates a colored warning log message in stdout
warning() {
    echo "\033[1;37m>>>\033[0m \033[1;33m$1\033[0m"
}

# Generates a colored error log message in stdout
error() {
    echo "\033[1;37m>>>\033[0m \033[1;31m$1\033[0m"
}

# Generates a colored start section text in stdout
section_start() {
    echo "\n\033[1;37m--- $1 ---\033[0m\n"
}

# Generates a colored end section text in stdout
section_end() {
    echo "\n\033[1;37m------\033[0m\n"
}

# Checks for availability of a given command.
# $1: Command name
# $2: Homebrew name
# $3: Display name
check_dependency() {
    if which $1 >/dev/null; then
        ok "$3 available"
    else
        info "Installing $3..."
        section_start "Homebrew output"
        brew install $2
        section_end
    fi
}

section_start "This script will set up the development environment by downloading all dependencies and generating all code."
if [[ -z $1 || -z $2 ]]; then
    error "No API ID or API hash were provided."
    error "Please specify them as arguments."
    error "Example of calling this script the right way:
        ./setup_environment.sh <api_id> <api_hash>"
    echo
    error "Exiting..."
    exit
fi

if which brew >/dev/null; then
    ok "Homebrew available"
else
    warning "No Homebrew installation found. Installing..."
    section_start "Installer output"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    section_end
fi

info "Checking dependencies...\n"

check_dependency swiftformat swiftformat SwiftFormat
check_dependency swiftlint swiftlint SwiftLint
check_dependency gyb ggoraa/brew/gyb GYB
check_dependency swiftgen swiftgen SwiftGen
check_dependency sourcery sourcery Sourcery

PIP_OUTPUT=`pip3 list | grep plistlib`
if [$PIP_OUTPUT -ne ""]; then
    echo "Python plistlib library is available, skipping installation"
else
    pip3 install plistlib
fi

cd Utilities/Templates
info "Running GYB..."
mkdir ../Sources/Utilities/Generated
find . -name "*.gyb" |
while read file; do
    filename=$(echo "$file" | sed 's/.\///')
    API_ID=$1 API_HASH=$2 gyb --line-directive '' -o "../Sources/Utilities/Generated/${filename%.gyb}" "$filename";
done

#info "Running Sourcery..."
#cd ../..
#info "If you get a password input prompt, it is for making sourcery.sh file executable"
#sudo chmod +x sourcery.sh
#section_start "Sourcery output"
#./sourcery.sh
#section_end

ok "Finished environment setup!"
