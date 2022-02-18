#!/bin/sh

# GYB
if which gyb >/dev/null; then
    echo "GYB is available, skipping installation"
else
    brew install nshipster/formulae/gyb
fi

cd Generated
find . -name "*.gyb" |
while read file; do
    gyb --line-directive '' -o "Sources/Generated/${file%.gyb}" "$file";
done
