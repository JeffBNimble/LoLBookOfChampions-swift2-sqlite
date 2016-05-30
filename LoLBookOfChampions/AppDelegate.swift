//
//  AppDelegate.swift
//  LoLBookOfChampions
//
//  Created by Jeffrey Roberts on 6/15/15.
//  Copyright (c) 2015 NimbleNoggin.io. All rights reserved.
//

import UIKit
import LoLDataDragonContentProvider
import ReactiveCocoa
import SwiftContentProvider
import SwiftProtocolsSQLite
import SwiftyBeaver


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let logger = SwiftyBeaver.self
    var fileManager : NSFileManager?

    var backgroundQueue : dispatch_queue_t! {
        didSet {
            self.backgroundScheduler = QueueScheduler(queue: backgroundQueue, name: "io.nimblenoggin.lolbookofchampions.background_queue")
        }
    }
    
    private var backgroundScheduler : QueueScheduler!
    var contentResolver : ContentResolver!
    var dataDragonDatabaseQueue : dispatch_queue_t! {
        didSet {
            self.dataDragonDatabaseScheduler = QueueScheduler(queue: dataDragonDatabaseQueue, name: "io.nimblenoggin.lolbookofchampions.datadragon.database_queue")
        }
    }
    
    private var dataDragonDatabaseScheduler : QueueScheduler!
    var dataDragon : DataDragon!
    var window : UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        self.initializeApplication()
        logger.debug("The application didFinishLaunchingWithOptions")
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        logger.debug("The application willResignActive")
    }

    func applicationDidEnterBackground(application: UIApplication) {
        logger.debug("The application didEnterBackground")
    }

    func applicationWillEnterForeground(application: UIApplication) {
        logger.debug("The application willEnterForeground")
    }

    func applicationDidBecomeActive(application: UIApplication) {
        logger.debug("The application didBecomeActive")
    }

    func applicationWillTerminate(application: UIApplication) {
        logger.debug("The application willTerminate")
    }
    
    func getBackgroundScheduler() -> QueueScheduler {
        return backgroundScheduler
    }
    
    func getDataDragonDatabaseScheduler() -> QueueScheduler {
        return dataDragonDatabaseScheduler
    }
    
    private func addConsoleLoggerDestination() {
        let consoleDestination = ConsoleDestination()
        consoleDestination.minLevel = .Debug
        consoleDestination.colored = false
        logger.addDestination(consoleDestination)
    }
    
    private func addFileLoggerDestination() {
        let fileDestination = FileDestination()
        fileDestination.minLevel = .Debug
        fileDestination.colored = false
        
        guard let url = fileManager?.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] else {
            return
        }
        
        do {
            try fileManager?.createDirectoryAtURL(url.URLByAppendingPathComponent("logs"), withIntermediateDirectories: true, attributes: nil)
        } catch {
            logger.error(error)
            return
        }
        
        let logFileURL = NSURL(string: "\(url.absoluteString)\("logs/lolChampionBrowser.log")")
        fileDestination.logFileURL = logFileURL
        logger.addDestination(fileDestination)
    }
    
    private func initializeApplication() {
        self.initializeLogger()
        self.initializeApplicationURLCache()
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        self.syncDataDragon()
    }
    
    private func initializeApplicationURLCache() {
        let urlCache = NSURLCache(memoryCapacity: 2 * 1024 * 1024, diskCapacity: 400 * 1024 * 1024, diskPath: "championImageCache")
        NSURLCache.setSharedURLCache(urlCache)
    }
    
    private func initializeLogger() {
        addConsoleLoggerDestination()
        addFileLoggerDestination()
    }

    private func syncDataDragon() {
        let queue = dispatch_queue_create("io.nimbleNoggin.LoLBookOfChampions.dataDragon.sync", DISPATCH_QUEUE_CONCURRENT)

        // Have to dispatch to a concurent queue instead of using RC3 scheduler to get true non-serial concurrency
        dispatch_async(queue, {
            self.dataDragonSyncAction()
            .apply(())
            .startWithCompleted() {
                self.logger.debug("DataDragon sync completed")
            }
        })
    }

}

