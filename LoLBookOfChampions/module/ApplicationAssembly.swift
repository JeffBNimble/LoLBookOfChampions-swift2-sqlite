//
//  AppAssembly.swift
//  LoLBookOfChampions
//
//  Created by Jeff Roberts on 8/16/15.
//  Copyright © 2015 NimbleNoggin.io. All rights reserved.
//

import Foundation
import Typhoon
import UIKit

class ApplicationAssembly : TyphoonAssembly {
    var core : CoreAssembly!
    var dataDragon : DataDragonAssembly!
    
    override init() {
        super.init()
    }
    
    dynamic func appDelegate() -> AnyObject {
        return TyphoonDefinition.withClass(AppDelegate.self) { definition in
            definition.injectProperty("dataDragon", with: self.dataDragon.dataDragon())
            //definition.injectProperty("contentResolver", with:self.core.contentResolver())
            definition.injectProperty("loggers", with: [self.core.consoleLogger()])
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