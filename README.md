# Moc
A (really) native and powerful macOS Telegram client, optimized
for moderating large communities and personal use. 

# Screenshots
Will be available later! 📸

# Building

_Work in progress..._

## Step 1 - Download right version of Xcode

The development is going with Xcode 13.2. You csn download it from
[Apple Developer](https://developer.apple.com/download/release/).

## Step 2 - Install dependencies

Dependencies are downloaded using Homebrew:
```shell
brew install swiftlint
brew install nshipster/formulae/gyb
```

This will download SwiftLint for code checking and linting,
and Swift GYB for code generation.

## Step 3 - Obtain `api_id` and `api_hash`

They can be obtained at my.telegram.org. Log in, open
**API devevelolment tools**, and fill up needed info. Then click **Save changes**
at the bottom of the page. Leave the page open, this will be needed in the next step!

## Step 4 - Paste these in Xcode

Open the project in Xcode. Wait until all dependencies are resolved(it will take a while,
at least because of a 300~ MB TDLib build)!

Then click on app target in the toolbar > Edit schemes > Arguments, and fill up needed environment variables.

Done! You have everything set up. You can now build Moc 😁
