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
    private let sink : Event<(Uri, ContentOperation), NoError>.Sink
    init(sink: Event<(Uri, ContentOperation), NoError>.Sink) {
        self.sink = sink
    }
    
    @objc func onUpdate(contentUri: Uri, operation: ContentOperation) {
        sendNext(sink, (contentUri, operation))
    }
}

public func uriChangeSignal(contentUri: Uri,
    contentResolver: ContentResolver,
    notifyForDescendents: Bool,
    operations: [ContentOperation]? = [],
    initialOperation: ContentOperation?) -> SignalProducer<(Uri, ContentOperation), NoError> {
        return SignalProducer<(Uri, ContentOperation), NoError>() { observer, disposable in
            let contentObserver = AppContentObserver(sink: observer)
            contentResolver.registerContentObserver(contentUri, notifyForDescendents: notifyForDescendents, contentObserver: contentObserver)
            
            guard let initialOperation = initialOperation else {
                return
            }
            
            contentResolver.notifyChange(contentUri, operation: initialOperation)
    }
    .filter() { (uri, operation) in
        guard let operations = operations where !operations.isEmpty else {
            return true
        }
        
        return operations.indexOf(operation) != nil
    }
}