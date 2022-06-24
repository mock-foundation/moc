#!/bin/zsh
#
# This script will set up development environment.
#

#set -euo pipefail
setopt extended_glob

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

section_start "This script will set up (and tear down) the development environment by downloading all dependencies and generating all code."

if [ "$1" = "teardown" ]; then
    warning "This task will remove swiftformat, swiftlint, gyb, swiftgen, and sourcery Homebrew packages."
    warning "It also clears all generated code."
    if read -q "choice?You definetely want to tear down the environment? Y/n "; then
        echo
        info "Running brew..."
        section_start "Homebrew output"
        brew remove swiftformat
        brew remove swiftlint
        brew remove gyb
        brew remove swiftgen
        brew remove sourcery
        section_end
        info "Removing generated code..."
        rm -rf Sources/Utilities/Generated
        rm -rf Moc/Generated
        ok "Finished!"
        exit 0
    else
        echo
        info "Alright, exiting..."
        exit 0
    fi
fi

if [ $# -eq 0 ] || [ $# -eq 1 ]; then
    error "No API ID or API hash were provided."
    error "Please specify them as arguments."
    error "Example of calling this script the right way:
        ./setup_environment.sh <api_id> <api_hash>"
    echo
    error "Exiting..."
    exit 1
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

check_dependency swiftlint swiftlint SwiftLint
check_dependency gyb ggoraa/apps/gyb GYB
check_dependency swiftgen swiftgen SwiftGen
check_dependency sourcery sourcery Sourcery

#PIP_OUTPUT=`pip3 list | grep plistlib`
#if [$PIP_OUTPUT -ne ""]; then
#    pip3 install plistlib
#else
#    echo "Python plistlib library is available, skipping installation"
#fi

cd Utilities/Templates
info "Running GYB..."
mkdir ../Sources/Utilities/Generated
find . -name "*.gyb" |
while read file; do
    filename=$(echo "$file" | sed 's/.\///')
    API_ID=$1 API_HASH=$2 gyb --line-directive '' -o "../Sources/Utilities/Generated/${filename%.gyb}" "$filename";
done

cd ../..

if [ "${FETCH_SPM}" = "1" ]; then
    info "Fetch SPM dependencies up front: using env imported choice..."
    info "Running xcodebuild..."
    section_start "xcodebuild output"
    xcodebuild -resolvePackageDependencies
    section_end
elif [ "${FETCH_SPM}" = "0" ]; then
    info "Fetch SPM dependencies up front: using env imported choice..."
    info "Skipping..."
else
    if read -q "choice?Fetch SPM dependencies up front? Y/n "; then
        echo
        info "Running xcodebuild..."
        section_start "xcodebuild output"
        xcodebuild -resolvePackageDependencies
        section_end
    else
        echo
        ok "Skipped."
    fi
fi

info "Running Sourcery..."
info "If you get a password input prompt, don't fear, it's for making sourcery.sh executable"
chmod +x sourcery.sh
section_start "Sourcery output"
./sourcery.sh
section_end


if [ "${OPEN_XCODE}" = "1" ]; then
    info "Open Xcode: using env imported choice..."
    info "Opening Xcode..."
    open Moc.xcodeproj
elif [ "${OPEN_XCODE}" = "0" ]; then
    info "Open Xcode: using env imported choice..."
    info "Skipping..."
else
    if read -q "choice?Open Xcode? Y/n "; then
        echo
        info "Opening Xcode..."
        open Moc.xcodeproj
    else
        echo
    fi
fi

echo

ok "Finished environment setup!"
