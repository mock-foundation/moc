<p align="center">
  <img src="https://github.com/mock-foundation/moc/raw/master/Shared/Assets.xcassets/AppIcon.appiconset/icon_256x256.png">
</p>

<h1 align="center">Moc</h1>

<p align="center">
A (really) native and powerful Telegram client for macOS and iPadOS, optimized
for moderating large communities and personal use. 
</p>

![](https://img.shields.io/badge/platform-macOS,%20iPadOS-000000?style=flat&logo=apple&logoColor=white)
![](https://img.shields.io/badge/minimum%20OS-macOS%2012,%20iPadOS%2015.2-blueviolet?style=flat&logo=apple&logoColor=white)
![](https://img.shields.io/badge/Swift%205.7-FA7343?style=flat&logo=swift&logoColor=white)
![](https://img.shields.io/badge/SwiftUI-2E00F1?style=flat&logo=swift&logoColor=white)
![](https://img.shields.io/badge/Telegram-2CA5E0?style=flat&logo=telegram&logoColor=white)
[![Build app](https://github.com/ggoraa/moc/actions/workflows/build.yml/badge.svg)](https://github.com/ggoraa/moc/actions/workflows/build.yml)
[![GPLv3 License](https://img.shields.io/badge/License-GPL%20v3-yellow.svg?style=flat)](https://opensource.org/licenses/)
[![Github All Releases](https://img.shields.io/github/downloads/ggoraa/moc/total.svg?style=flat)]() 

This client is currently **in development** and **barely usable**. You can track progress by observing the [project table](https://github.com/orgs/mock-foundation/projects/2), [issues](https://github.com/mock-foundation/moc/issues), [pull requests](https://github.com/mock-foundation/moc/pulls), and a [Telegram channel](https://t.me/moc_updates_ua) (russian, and soon ukrainian).

Project roadmap: [Craft](https://www.craft.do/s/rmUOSbIPXTVbCY)

If you have any questions, ask them in [Discussions](https://github.com/mock-foundation/moc/discussions) on GitHub, or in a [Telegram group](https://t.me/moc_discussion) (ukrainian/russian). You are **strongly** encoruaged to use Discussions and the Telegram group instead of Issues for questions. Bug reports and stuff go to Issues. There is a reason why GitHub created Discussions in the first place :D

# Screenshots
![](.github/images/screenshots/light/main.png)
![](.github/images/screenshots/dark/main.png)
![](.github/images/screenshots/light/about.png)
![](.github/images/screenshots/dark/about.png)
![](.github/images/screenshots/light/folders.png)
![](.github/images/screenshots/dark/folders.png)
![](.github/images/screenshots/light/account.png)
![](.github/images/screenshots/dark/account.png)

# Contributing

If you want to contribute a new feature, please make sure you have read the [project roadmap](https://www.craft.do/s/rmUOSbIPXTVbCY). This may guide you what are current goals of the project :D

# Building

## Step 1 - Clone

Use the command below to clone the repo and its submodules:

```shell
git clone --recurse-submodules https://github.com/mock-foundation/moc.git 
```

## Step 2 - Download right version of Xcode

The development is going with **Xcode 14 beta**. You can download it from
[Apple Developer](https://developer.apple.com/download/release/).

## Step 3 - Obtain `api_id` and `api_hash`

They can be obtained [here](https://my.telegram.org/). Log in, open **API development tools**, and fill up needed info. Then click **Save changes**
at the bottom of the page. Leave the page open, this will be needed in the next step!

## Step 4 - Set up development environment

Be sure that you have [Homebrew](https://brew.sh) installed, because it is used a lot here.

Now run these commands:
```shell
brew install swift-sh
sudo chmod +x environment.swift 
sudo chmod +x gyb.sh
./environment.swift <api_id> <api_hash>
```

**Done!** You have everything set up. You can now build Moc 😁
