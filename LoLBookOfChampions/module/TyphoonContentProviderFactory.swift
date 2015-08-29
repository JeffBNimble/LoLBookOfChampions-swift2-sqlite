//
//  TyphoonContentProviderFactory.swift
//  LoLBookOfChampions
//
//  Created by Jeff Roberts on 8/22/15.
//  Copyright © 2015 NimbleNoggin.io. All rights reserved.
//

import Foundation
import SwiftContentProvider
import SwiftProtocolsCore
import LoLDataDragonContentProvider
import Typhoon

class TyphoonContentProviderFactory : ContentProviderFactory {
    private var dataDragonContentProvider : DataDragonContentProvider!
    private let factory : TyphoonComponentFactory
    
    init(factory: TyphoonComponentFactory) {
        self.factory = factory
    }
    
    override func create(type: NSObject.Type) throws -> ContentProvider {
        // This is a complete hack
        // Swift protocols that cannot be annotated with the @objc declaration
        // cannot be injectible components in Typhoon. This is a shortcoming of the
        // Swift runtime (or lack thereof) and not Typhoon.
        
        guard type == DataDragonContentProvider.self else {
            throw CoreError.UnsupportedOperationError
        }
        
        // Enforce singleton scope
        guard dataDragonContentProvider == nil else {
            return self.dataDragonContentProvider
        }
    
        // Use the injected factory to get the DataDragon instance
        let dataDragon = self.factory.componentForType(DataDragon.self) as! DataDragon
        let database = dataDragon.database
        
        return DataDragonContentProvider(database: database)
    }
}