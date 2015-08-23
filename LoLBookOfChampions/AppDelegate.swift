//
//  AppDelegate.swift
//  LoLBookOfChampions
//
//  Created by Jeffrey Roberts on 6/15/15.
//  Copyright (c) 2015 NimbleNoggin.io. All rights reserved.
//

import UIKit
import CocoaLumberjackSwift
import SwiftContentProvider
import LoLDataDragonContentProvider

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var loggers : [DDLogger]?
    var contentResolver : ContentResolver!
    var dataDragon : DataDragon!
    var dataDragonDispatchQueue : dispatch_queue_t!
    var window : UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        self.initializeApplication()
        DDLogInfo("The application has been initialized")
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    private func initializeApplication() {
        self.initializeLogger()
        self.initializeApplicationURLCache()
        self.syncDataDragon()
    }
    
    private func initializeApplicationURLCache() {
        let urlCache = NSURLCache(memoryCapacity: 2 * 1024 * 1024, diskCapacity: 400 * 1024 * 1024, diskPath: "championImageCache")
        NSURLCache.setSharedURLCache(urlCache)
    }
    
    private func initializeLogger() {
        guard let loggers = loggers else {
            return
        }
        
        loggers.forEach() { logger in
            DDLog.addLogger(logger)
        }
    }

    private func syncDataDragon() {
        self.dataDragonDispatchQueue = dispatch_queue_create("io.nimbleNoggin.LoLBookOfChampions.dataDragon", DISPATCH_QUEUE_SERIAL)
        
        dispatch_async(self.dataDragonDispatchQueue, {
            do {
                try self.dataDragon.sync()
            } catch {
                DDLogError("An error occurred attempting to sync Data Dragon: \(error)")
            }
        })
    }

}

