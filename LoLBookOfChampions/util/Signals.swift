//
//  Signals.swift
//  LoLBookOfChampions
//
//  Created by Jeff Roberts on 8/27/15.
//  Copyright © 2015 NimbleNoggin.io. All rights reserved.
//

import Foundation
import SwiftContentProvider
import SwiftProtocolsSQLite
import ReactiveCocoa

private class AppContentObserver : ContentObserver {
    private let observer : Observer<(Uri, ContentOperation), NoError>
    init(observer: Observer<(Uri, ContentOperation), NoError>) {
        self.observer = observer
    }
    
    @objc func onUpdate(contentUri: Uri, operation: ContentOperation) {
        observer.sendNext((contentUri, operation))
    }
}

public func uriChangeSignal(contentUri: Uri,
    contentResolver: ContentResolver,
    notifyForDescendents: Bool,
    operations: [ContentOperation]? = [],
    started: ContentObserver -> ()) -> SignalProducer<(Uri, ContentOperation), NoError> {
        return SignalProducer<(Uri, ContentOperation), NoError>() { observer, disposable in
            let contentObserver = AppContentObserver(observer: observer)
            contentResolver.registerContentObserver(contentUri, notifyForDescendents: notifyForDescendents, contentObserver: contentObserver)
            started(contentObserver)
    }
    .filter() { (uri, operation) in
        guard let operations = operations where !operations.isEmpty else {
            return true
        }
        
        return operations.indexOf(operation) != nil
    }
}