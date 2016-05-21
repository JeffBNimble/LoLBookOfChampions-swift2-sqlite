//
// Created by Jeffrey Roberts on 9/14/15.
// Copyright (c) 2015 NimbleNoggin.io. All rights reserved.
//

import Foundation
import LoLDataDragonContentProvider
import ReactiveCocoa
import SwiftProtocolsSQLite
import SwiftyBeaver

extension AppDelegate {
    func dataDragonSyncAction() -> Action<Void, Void, SQLError> {
        return Action<Void, Void, SQLError>() { input in
            return SignalProducer<Void, SQLError>() { observer, disposable in
                do {
                    try self.dataDragon.sync()
                } catch {
                    self.logger.error("An error occurred attempting to sync Data Dragon: \(error)")
                    observer.sendFailed(error as! SQLError)
                }
                observer.sendCompleted()
            }
        }
    }
}

extension ChampionCollectionViewDataSource {
    private var championCountProjection: [String] {
        get {
            return ["count(*) as \(ChampionCollectionViewDataSource.COLUMN_ROW_COUNT)"]
        }
    }

    func getChampionsAction() -> Action<Void, Cursor, SQLError> {
        return Action<Void, Cursor, SQLError>() {
            _ in
            return SignalProducer<Cursor, SQLError>() {
                observer, disposable in
                do {
                    let cursor = try self.contentResolver.query(DataDragonDatabase.Champion.uri,
                            projection: self.championProjection,
                            selectionArgs: nil,
                            sort: "\(DataDragonDatabase.Champion.Columns.name)")
                    observer.sendNext(cursor)
                } catch {
                    observer.sendFailed(error as! SQLError)
                }
            }
        }
    }

    func getChampionCountAction() -> Action<Void, Int, SQLError> {
        return Action<Void, Int, SQLError>() {
            _ in
            return SignalProducer<Int, SQLError>() {
                observer, disposable in
                do {
                    let cursor = try self.contentResolver.query(DataDragonDatabase.Champion.uri,
                            projection: self.championCountProjection,
                            selection: nil,
                            selectionArgs: [String](),
                            groupBy: nil,
                            having: nil,
                            sort: nil)

                    defer {
                        cursor.close()
                    }

                    observer.sendNext(cursor.moveToFirst() ? cursor.intFor(ChampionCollectionViewDataSource.COLUMN_ROW_COUNT) : 0)
                    observer.sendCompleted()

                } catch {
                    observer.sendFailed(error as! SQLError)
                }
            }
        }
    }
}

extension ChampionSkinCollectionViewDataSource {
    private var championSkinCountProjection : [String] {
        get {
            return ["count(*) as \(ChampionCollectionViewDataSource.COLUMN_ROW_COUNT)"]
        }
    }

    func getChampionSkinsAction() -> Action<Int, Cursor, SQLError> {
        return Action<Int, Cursor, SQLError>() { championId in
            return SignalProducer<Cursor, SQLError>() { observer, disposable in
                do {
                    let cursor = try self.contentResolver.query(DataDragonDatabase.ChampionSkin.uri,
                            projection: self.skinProjection,
                            selection: "\(DataDragonDatabase.ChampionSkin.Columns.championId) = :\(DataDragonDatabase.ChampionSkin.Columns.championId)",
                            namedSelectionArgs: ["\(DataDragonDatabase.ChampionSkin.Columns.championId)" : championId],
                            sort: "\(DataDragonDatabase.ChampionSkin.Columns.skinNumber)")
                    observer.sendNext(cursor)
                } catch {
                    observer.sendFailed(error as! SQLError)
                }
            }
        }
    }

    func getChampionSkinCountAction() -> Action<Int, Int, SQLError> {
        return Action<Int, Int, SQLError>() { championId in
            return SignalProducer<Int, SQLError>() {
                observer, disposable in
                do {
                    let cursor = try self.contentResolver.query(DataDragonDatabase.ChampionSkin.uri,
                            projection: self.skinCountProjection,
                            selection: "\(DataDragonDatabase.ChampionSkin.Columns.championId) = :\(DataDragonDatabase.ChampionSkin.Columns.championId)",
                            namedSelectionArgs: ["\(DataDragonDatabase.ChampionSkin.Columns.championId)" : championId])

                    defer {
                        cursor.close()
                    }

                    observer.sendNext(cursor.moveToFirst() ? cursor.intFor(ChampionCollectionViewDataSource.COLUMN_ROW_COUNT) : 0)
                    observer.sendCompleted()

                } catch {
                    observer.sendFailed(error as! SQLError)
                }
            }
        }
    }
}