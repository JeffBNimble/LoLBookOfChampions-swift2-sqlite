//
//  CoreAssembly.swift
//  LoLBookOfChampions
//
//  Created by Jeff Roberts on 8/16/15.
//  Copyright © 2015 NimbleNoggin.io. All rights reserved.
//

import Foundation
import CocoaLumberjackSwift
import LoLDataDragonContentProvider
import SwiftContentProvider
import Typhoon

class CoreAssembly : TyphoonAssembly {
    override init() {
        super.init()
    }
    
    dynamic func bundleIdentifier() -> AnyObject {
        return TyphoonDefinition.withFactory(self.mainBundle(), selector: "bundleIdentifier")
    }
    
    dynamic func consoleLogger() -> AnyObject {
        return TyphoonDefinition.withClass(DDTTYLogger.self) { definition in
            definition.useInitializer("sharedInstance")
        }
    }
    
    dynamic func contentProviderFactory() -> AnyObject {
        return TyphoonDefinition.withClass(TyphoonContentProviderFactory.self) { definition in
            definition.useInitializer("initWithFactory:") { initializer in
                initializer.injectParameterWith(self)
            }
        }
    }
    
    dynamic func contentResolver() -> AnyObject {
        return TyphoonDefinition.withClass(ContentResolver.self) { definition in
            definition.useInitializer("initWithContentProviderFactory:contentAuthorityBase:contentRegistrations:") { initializer in
                initializer.injectParameterWith(self.contentProviderFactory())
                initializer.injectParameterWith(self.bundleIdentifier())
                initializer.injectParameterWith([DataDragon.contentAuthority : DataDragonContentProvider.self])
            }
        }
    }
    
    dynamic func fileManager() -> AnyObject {
        return TyphoonDefinition.withClass(NSFileManager.self) { definition in
            definition.useInitializer("defaultManager")
        }
    }
    
    dynamic func mainBundle() -> AnyObject {
        return TyphoonDefinition.withClass(NSBundle.self) { definition in
            definition.useInitializer("mainBundle")
        }
    }
    
    dynamic func notificationCenter() -> AnyObject {
        return TyphoonDefinition.withClass(NSNotificationCenter.self) { definition in
            definition.useInitializer("defaultCenter")
        }
    }
    
    dynamic func sharedURLCache() -> AnyObject {
        return TyphoonDefinition.withClass(NSURLCache.self) { definition in
            definition.useInitializer("sharedURLCache")
            definition.scope = .LazySingleton
        }
    }
    
}