#!/bin/zsh

cd Utilities/Templates
mkdir ../Sources/Utilities/Generated
find . -name "*.gyb" |
while read file; do
    filename=$(echo "$file" | sed 's/.\///')
    gyb --line-directive '' -o "../Sources/Utilities/Generated/${filename%.gyb}" "$filename";
done

cd ../..
