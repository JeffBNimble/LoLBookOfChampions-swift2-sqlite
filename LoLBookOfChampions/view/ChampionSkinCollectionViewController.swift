//
//  ChampionSkinCollectionViewController.swift
//  LoLBookOfChampions
//
//  Created by Jeff Roberts on 8/29/15.
//  Copyright © 2015 NimbleNoggin.io. All rights reserved.
//

import Foundation
import LoLDataDragonContentProvider
import ReactiveCocoa
import SwiftContentProvider
import SwiftProtocolsSQLite
import SwiftyBeaver

class ChampionSkinCell : UICollectionViewCell {
    @IBOutlet weak var skinImageView : UIImageView!
    @IBOutlet weak var skinNameLabel : UILabel!
    
    override func prepareForReuse() {
        self.skinImageView.image = nil
        self.skinNameLabel.text = ""
    }
}

class ChampionSkinCollectionViewController : UICollectionViewController {
    var championId : Int!
    var championName : String!
    var championTitle : String!
    
    var dataSource : ChampionSkinCollectionViewDataSource!

    private var disposables : [Disposable] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "\(self.championName), \(self.championTitle)"
        
        self.collectionView?.dataSource = self.dataSource
        self.collectionView?.delegate = self.dataSource
        
        self.dataSource.championId = self.championId
    }
    
    override func viewWillAppear(animated: Bool) {
        // Setup the signals
        self.disposables.append(
            self.dataSource.getContentSignal()
                .observeOn(QueueScheduler.mainQueueScheduler)
                .startWithNext() {  count, cursor in
                    self.dataSource.skinsCount = count
                    self.dataSource.skinCursor = cursor
                    self.collectionView?.reloadData()
                }
        )

    }
    
    override func viewWillDisappear(animated: Bool) {
        self.disposables.forEach() { disposable in
            disposable.dispose()
        }
        self.disposables.removeAll()
        
        self.dataSource.skinsCount = 0
        if self.dataSource.skinCursor != nil {
            self.dataSource.skinCursor.close()
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        self.collectionViewLayout.invalidateLayout()
        
        dispatch_async(dispatch_get_main_queue(), {
            self.clearImagesInVisibleCells()
            var indexPaths = self.collectionView!.indexPathsForVisibleItems()
            
            if indexPaths.isEmpty {
                indexPaths = [NSIndexPath(forRow: self.dataSource.skinsCount - 1, inSection: 0)]
            }
            
            self.collectionView?.reloadItemsAtIndexPaths(indexPaths)
            self.collectionView?.scrollToItemAtIndexPath((indexPaths.first)!, atScrollPosition: .Top, animated: true)
        })
    }

    private func clearImagesInVisibleCells() {
        let visibleCells = self.collectionView?.visibleCells()
        visibleCells!.forEach() { cell in
            let skinCell = cell as! ChampionSkinCell
            skinCell.skinImageView.image = nil
        }
    }
}

class ChampionSkinCollectionViewDataSource : NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    private static let COLUMN_ROW_COUNT = "row_count"
    private let logger = SwiftyBeaver.self
    
    var championId : Int!
    
    var skinCountProjection : [String] {
        get {
            return ["count(*) as \(ChampionSkinCollectionViewDataSource.COLUMN_ROW_COUNT)"]
        }
    }
    
    var skinProjection : [String] {
        get {
            return [
                DataDragonDatabase.ChampionSkin.Columns.portraitImageUrl,
                DataDragonDatabase.ChampionSkin.Columns.landscapeImageUrl,
                DataDragonDatabase.ChampionSkin.Columns.name
            ]
        }
    }
    
    private var skinsCount = 0
    private var skinCursor : Cursor! {
        willSet {
            if skinCursor != nil {
                skinCursor.close()
            }
        }
    }

    let contentResolver : ContentResolver
    
    init(contentResolver : ContentResolver) {
        self.contentResolver = contentResolver
        super.init()
    }

    func getContentSignal() -> SignalProducer<(Int, Cursor), SQLError> {
        return SignalProducer<(Int, Cursor), SQLError>() { observer, disposable in
            var count : Int!
            var cursor : Cursor!

            // Retrieve the count of champion skins
            self.getChampionSkinCountAction().apply(self.championId)
            .startWithNext() { championSkinCount in
                count = championSkinCount
            }

            // Retrieve the champions cursor
            self.getChampionSkinsAction().apply(self.championId)
            .startWithNext() { championSkinCursor in
                cursor = championSkinCursor
            }

            observer.sendNext((count, cursor))
            observer.sendCompleted()
        }.startOn(dataDragonDatabaseScheduler)
    }
    
    private func isPortraitOrientation(view: UIView) -> Bool {
        return CGRectGetHeight(view.frame) > CGRectGetWidth(view.frame)
    }
    
    // MARK: UICollectionViewDataSource methods
    
    @objc func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.skinsCount
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    @objc func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCellWithReuseIdentifier("championSkinCell", forIndexPath: indexPath)
    }
    
    // MARK: UICollectionViewDelegate methods
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        guard self.skinCursor != nil && self.skinCursor.moveToPosition(indexPath.row) else {
            logger.error("Unable to move cursor \(self.skinCursor) to \(indexPath.row)")
            return
        }
        
        let skinCell = cell as! ChampionSkinCell
        skinCell.skinNameLabel.text = self.skinCursor.stringFor(DataDragonDatabase.ChampionSkin.Columns.name)
        
        let column = self.isPortraitOrientation(collectionView) ? DataDragonDatabase.ChampionSkin.Columns.portraitImageUrl : DataDragonDatabase.ChampionSkin.Columns.landscapeImageUrl
        let imageURL = NSURL(string: self.skinCursor.stringFor(column))
        let urlRequest = NSURLRequest(URL: imageURL!, cachePolicy: .ReturnCacheDataElseLoad, timeoutInterval: 30)
        skinCell.skinImageView.setImageWithURLRequest(urlRequest, placeholderImage: nil, success: { _, _, image in
            skinCell.skinImageView.image = image
            skinCell.skinImageView.setNeedsDisplay()
            }, failure: nil)
    }
    
    // MARK: UICollectionViewDelegateFlowLayout methods
    @objc func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return collectionView.frame.size
    }
}