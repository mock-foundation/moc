cd Utilities/Templates
mkdir ../Sources/Utilities/Generated
find . -name "*.gyb" |
while read file; do
    filename=$(echo "$file" | sed 's/.\///')
    API_ID=$1 API_HASH=$2 APP_CENTER_SECRET=$3 gyb --line-directive '' -o "../Sources/Utilities/Generated/${filename%.gyb}" "$filename";
done

cd ../..
