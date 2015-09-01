# Installation
* This application is written using Swift 2 and requires XCode 7 or later. If you're running an earlier version of XCode, you must use xcode-select to switch the compiler using ```sudo xcode-select -s /Applications/Xcode-beta.app/Contents/Developer```
* Use [Carthage](https://github.com/Carthage/Carthage) and run ```carthage update --platform ios```. If you get a codesign error building ReactiveCocoa, retry by running ```carthage build --platform ios```. You may have to retry multiple times. If you can never get this to work, see [this post](https://github.com/Carthage/Carthage/issues/418).
* Use [CocoaPods](http://www.cocoapods.org), navigate to the project folder containing the podfile and run `pod install`
* Open the workspace in XCode 7, compile and run the app.

**Warning**

Please note that running this application on your device will take up approximately 360MB of disk space. The entire set of League of Legends images are cached. You should make sure that you run this application while connected to WiFi or you will use 350MB of data as soon as the app launches.

# Introduction
LoL Book of Champions is an iOS application that is more a playground for some key tech I wanted to play with than anything else. However, it is a simple League of Legends Champion Browser. I am fortunate to work at Riot Games and this application also shows off the champion imagery from the talented artists at Riot Games. It uses the [Riot Games Developer API](http://developer.riotgames.com) to obtain champion data.

**NOTE**
The application uses my personal Riot Games Developer API key to access the service to retrieve champion data. If you do anything more than run the app once to see it, please register for your own key at [http://developer.riotgames.com](http://developer.riotgames.com). It's free. If you already have a League of Legends account, just login with your LoL credentials to get your key.

The application has only two screens:

##Champions
A UICollectionViewController-based screen which shows a list of champions for the latest released version of League of Legends

![Champions Screen](documentation/championPage.gif)

##Champion Skins
A UICollectionViewController-based screen which shows a list of skins for the selected champion. If you switch between portrait and landscape orientations, the images show the loading skin image (portrait) and the splash screen skin image (landscape)

![Champion Skins Screen](documentation/championSkinScreenshot.jpg)

#Goals
* Build a Swift 2 version of [this](https://github.com/JeffBNimble/LoLBookOfChampions-ios-sqlite)
* Use size classes to support iOS 9 multitasking
* Try out a compelling mobile framework-based application architecture (more on this below)
* Use Carthage
* Use ReactiveCocoa
* Use Quick and Nimble for testing
* Have fun!

Not all of my goals were met. I've yet to be able to spend much time with size classes and unfortunately, I've written no tests. This version of the application took much longer to write than the Objective-C version. I plan to continue working with the application, slowly adding more features, but mainly use it as a playground for a tech stack that I'm interested in.

#Tech Stack (in no particular order)
* [Swift 2.0](https://developer.apple.com/swift/?cid=wwa-us-kwg-features) : Using the newest features of the language including throws, guards and generics
* [Typhoon](https://github.com/appsquickly/Typhoon) : A very nice dependency injection library for iOS/OSX (Objective-C and Swift)
* [FMDB](https://github.com/ccgus/fmdb) : A clean and simple Objective-C wrapper around SQLite
* [Alamofire](https://github.com/Alamofire/Alamofire) : The defacto standard networking library for Swift, if such a thing yet exists
* [AFNetworking](https://github.com/AFNetworking/AFNetworking) : Using only the UIImage extensions for asynchronously loading UIImage's
* [Reactive Cocoa 3](https://github.com/ReactiveCocoa/ReactiveCocoa) : Functional Reactive Programming for iOS [ReactiveX.org](http://ReactiveX.org)
* [CocoaLumberjack](https://github.com/CocoaLumberjack/CocoaLumberjack) : Logging (duh, what else do lumberjacks do?)
* [] [SceneKit](https://developer.apple.com/library/ios/documentation/SceneKit/Reference/SceneKit_Framework/) : To add a little ambient magic to the application
* [Quick](https://github.com/Quick/Quick)/[Nimble](https://github.com/Quick/Nimble) : If you write code, you better write tests

# Application Architecture
While the application architecture may not be all the novel, it is based upon some simple principles:

* Persist early and often, enabling offline use once all images are cached
* Stay off of the main thread so the application always remains responsive
* Code is unit testable (not yet fully unit tested, though some tests exist)
* Employ extreme modularity, assembling the application from modules

The application itself is mostly just UI. The rest is assembled from frameworks which have no knowledge of the application.

##Screencasts
I have created a [YouTube Channel](https://www.youtube.com/channel/UCUMAujrLQP-zB925se5YIiQ) with several playlists that use this application as an example. I'm adding videos regularly. Most of the videos are short (5-6 minutes or less) and are intended to help you learn more about iOS development. Feel free to subscribe, leave feedback and learn!

* Videos will be posted here as they become available
