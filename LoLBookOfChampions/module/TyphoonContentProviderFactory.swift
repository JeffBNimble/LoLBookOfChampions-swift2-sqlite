//
//  TyphoonContentProviderFactory.swift
//  LoLBookOfChampions
//
//  Created by Jeff Roberts on 8/22/15.
//  Copyright © 2015 NimbleNoggin.io. All rights reserved.
//

import Foundation
import SwiftContentProvider
import Typhoon

class TyphoonContentProviderFactory : ContentProviderFactory {
    private let factory : TyphoonComponentFactory
    
    init(factory: TyphoonComponentFactory) {
        self.factory = factory
    }
    
    override func create(type: NSObject.Type) throws -> ContentProvider {
        return self.factory.componentForType(type) as! ContentProvider
    }
}