//
//  DataDragonAssembly.swift
//  LoLBookOfChampions
//
//  Created by Jeff Roberts on 8/16/15.
//  Copyright © 2015 NimbleNoggin.io. All rights reserved.
//

import Foundation
import LoLDataDragonContentProvider
import SwiftAdaptersFMDB
import Typhoon

class DataDragonAssembly : TyphoonAssembly {
    var core : CoreAssembly!
    
    override init() {
        super.init()
    }

    func dataDragonConfig() -> AnyObject {
        return TyphoonDefinition.configDefinitionWithName("DataDragon.plist")
    }
    
    dynamic func databaseFactory() -> AnyObject {
        return TyphoonDefinition.withClass(FMDBDatabaseFactory.self) { definition in
            definition.useInitializer("init")
        }
    }
    
    dynamic func dataDragon() -> AnyObject {
        return TyphoonDefinition.withClass(DataDragon.self) { definition in
            definition.useInitializer("initWithDatabaseFactory:contentResolver:apiKey:contentAuthorityBase:urlCache:databaseName:region:databaseDispatchQueue:") { initializer in
                initializer.injectParameterWith(self.databaseFactory())
                initializer.injectParameterWith(self.core.contentResolver())
                initializer.injectParameterWith(TyphoonConfig("datadragon.api.key"))
                initializer.injectParameterWith(self.core.bundleIdentifier())
                initializer.injectParameterWith(self.core.sharedURLCache())
                initializer.injectParameterWith(TyphoonConfig("datadragon.database.name"))
                initializer.injectParameterWith(TyphoonConfig("datadragon.lol.region"))
                initializer.injectParameterWith(dataDragonDatabaseQueue) // Database dispatch queue
            }
        }
    }
    
    dynamic func dataDragonDatabase() -> AnyObject {
        return TyphoonDefinition.withFactory(self.dataDragon(), selector: "database")
    }
}