# Moc
A (really) native and powerful macOS Telegram client, optimized
for moderating large communities and personal use. 

This client is currently **in development** and **not usable**. You can track progress by observing the [project table](https://github.com/users/ggoraa/projects/1), [issues](https://github.com/ggoraa/moc/issues), [pull requests](https://github.com/ggoraa/moc/pulls), and a [Telegram channel](https://t.me/moc_updates_ru) (russian).

If you have any questions, ask them in [Discussions](https://github.com/ggoraa/moc/discussions) on GitHub, or in a [Telegram group](https://t.me/moc_discussion) (russian). You are **strongly** encoruaged to use Discussions and the Telegram group instead of Issues.

# Screenshots
![](images/screenshots/light/main.png)
![](images/screenshots/dark/main.png)

# Building

## Step 1 - Download right version of Xcode

The development is going with Xcode 13.2. You can download it from
[Apple Developer](https://developer.apple.com/download/release/).

## Step 2 - Obtain `api_id` and `api_hash`

They can be obtained at my.telegram.org. Log in, open **API devevelolment tools**, and fill up needed info. Then click **Save changes**
at the bottom of the page. Leave the page open, this will be needed in the next step!

## Step 3 - Set up development environment

Open the project in Xcode. Wait until all dependencies are resolved(it will take a while, at least because of a 300~ MB TDLib build!)

After that, open Moc project from Project navigator:

![](images/project.png)

Select `Moc` target:

![](images/target.png)

Open `Build Phases` tab:

![](images/build-phases.png)

Expand `GYB Code generation` item:

![](images/gyb-phase.png)

And insert previously obtained` api_id` and `api_hash` in corresponding places:

![](images/env.png)

**WARNING: DO NOT commit your `api_id` and `api_hash`. They should be kept private.**

**Done!** You have everything set up. You can now build Moc 😁
