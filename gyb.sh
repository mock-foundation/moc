cd Utilities/Templates
mkdir ../Sources/Utilities/Generated
find . -name "*.gyb" |
while read file; do
    filename=$(echo "$file" | sed 's/.\///')
    API_ID=$1 API_HASH=$2 MACOS_APP_CENTER_SECRET=$3 IPADOS_APP_CENTER_SECRET=$4 gyb --line-directive '' -o "../Sources/Utilities/Generated/${filename%.gyb}" "$filename";
done

cd ../..
