//
//  AppAssembly.swift
//  LoLBookOfChampions
//
//  Created by Jeff Roberts on 8/16/15.
//  Copyright © 2015 NimbleNoggin.io. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Typhoon
import UIKit

// Global dispatch_queues and Schedulers
// This is a workaround/hack to get around the limitation that Schedulers cannot be assembled/injected
let backgroundDispatchQueue = dispatch_queue_create("io.nimblenoggin.lolbookofchampions.background_queue", DISPATCH_QUEUE_CONCURRENT)
let backgroundScheduler = QueueScheduler(queue: backgroundDispatchQueue, name: "io.nimblenoggin.bookofchampions.background_scheduler")
let dataDragonDatabaseQueue = dispatch_queue_create("io.nimblenoggin.lolbookofchampions.datadragon.database_queue", DISPATCH_QUEUE_SERIAL)
let dataDragonDatabaseScheduler = QueueScheduler(queue: dataDragonDatabaseQueue, name: "io.nimblenoggin.lolbookofchampions.datadragon_database_scheduler")

class ApplicationAssembly : TyphoonAssembly {
    var core : CoreAssembly!
    var dataDragon : DataDragonAssembly!
    
    override init() {
        super.init()
    }
    
    dynamic func appDelegate() -> AnyObject {
        return TyphoonDefinition.withClass(AppDelegate.self) { definition in
            definition.injectProperty("backgroundQueue", with: backgroundDispatchQueue)
            definition.injectProperty("dataDragonDatabaseQueue", with: dataDragonDatabaseQueue)
            definition.injectProperty("dataDragon", with: self.dataDragon.dataDragon())
            definition.injectProperty("loggers", with: [self.core.consoleLogger()])
        }
    }
    
    dynamic func championCollectionViewController() -> AnyObject {
        return TyphoonDefinition.withClass(ChampionCollectionViewController.self) { definition in
            definition.injectProperty("dataSource", with: self.championCollectionViewDataSource())
            definition.injectProperty("mainBundle", with: self.core.mainBundle())
        }
    }
    
    dynamic func championCollectionViewDataSource() -> AnyObject {
        return TyphoonDefinition.withClass(ChampionCollectionViewDataSource.self) { definition in
            definition.useInitializer("initWithContentResolver:") { initializer in
                initializer.injectParameterWith(self.core.contentResolver())
            }
        }
    }
    
    dynamic func championSkinCollectionViewController() -> AnyObject {
        return TyphoonDefinition.withClass(ChampionSkinCollectionViewController.self) { definition in
            definition.injectProperty("dataSource", with: self.championSkinCollectionViewDataSource())
        }
    }
    
    dynamic func championSkinCollectionViewDataSource() -> AnyObject {
        return TyphoonDefinition.withClass(ChampionSkinCollectionViewDataSource.self) { definition in
            definition.useInitializer("initWithContentResolver:") { initializer in
                initializer.injectParameterWith(self.core.contentResolver())
            }
        }
    }

    dynamic func currentDevice() -> AnyObject {
        return TyphoonDefinition.withClass(UIDevice.self) { definition in
            definition.useInitializer("currentDevice")
        }
    }
    
    dynamic func mainScreen() -> AnyObject {
        return TyphoonDefinition.withClass(UIScreen.self) { definition in
            definition.useInitializer("mainScreen")
        }
    }
}