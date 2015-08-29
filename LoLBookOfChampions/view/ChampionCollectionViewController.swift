//
//  ChampionCollectionViewController.swift
//  LoLBookOfChampions
//
//  Created by Jeff Roberts on 8/16/15.
//  Copyright © 2015 NimbleNoggin.io. All rights reserved.
//

import Foundation
import CocoaLumberjackSwift
import LoLDataDragonContentProvider
import ReactiveCocoa
import SceneKit
import SpriteKit
import SwiftContentProvider
import SwiftProtocolsSQLite

class ChampionCell : UICollectionViewCell {
    @IBOutlet weak var championImageView : UIImageView!
    @IBOutlet weak var championNameLabel : UILabel!
}

class ChampionCollectionViewController : UICollectionViewController, UINavigationControllerDelegate {
    var dataSource : ChampionCollectionViewDataSource!
    var mainBundle : NSBundle!
    
    private var disposables : [Disposable] = []
    private var magic : SKEmitterNode!
    private var magicColors : [UIColor]!
    private var magicScene : SKScene!
    private var magicView : SKView!
    private var presentNewMagicScene : Bool = false
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initialize()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController!.delegate = self
        self.collectionView?.dataSource = self.dataSource
        self.collectionView?.delegate = self.dataSource
        
        self.magicView = SKView(frame: self.view.frame)
        self.magicView.asynchronous = true
        self.view.addSubview(self.magicView)
        self.view.sendSubviewToBack(self.magicView)
        self.presentNewMagicScene = true
        
        // Setup the signals
        self.disposables.append(
            combineLatest(self.dataSource.championCountSignal(), self.dataSource.championsSignal())
            .observeOn(UIScheduler())
            .start(next: { count, cursor in
                self.dataSource.championsCount = count
                self.dataSource.championCursor = cursor
                self.collectionView?.reloadData()
            })
        )
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if presentNewMagicScene {
            self.presentMagicParticleScene()
            self.presentNewMagicScene = false
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        self.presentNewMagicScene = true
    }
    
    private func assignRandomMagicColor() {
        let colorIndex = Int(rand()) % self.magicColors.count
        print("The new color index is \(colorIndex)")
        self.magic.particleColor = self.magicColors[colorIndex]
    }
    
    private func initialize() {
        self.mainBundle = NSBundle(forClass: ChampionCollectionViewController.self)
        self.magicColors = [UIColor.redColor(), UIColor.greenColor(), UIColor.blueColor(), UIColor.orangeColor(), UIColor.purpleColor()]
        self.magic = NSKeyedUnarchiver.unarchiveObjectWithFile(self.mainBundle.pathForResource("magic", ofType: "sks")!) as! SKEmitterNode
    }
    
    private func presentMagicParticleScene() {
        let frame = self.view.frame
        self.magicView.frame = frame
        self.magicScene = SKScene(size: frame.size)
        self.magicScene.scaleMode = .AspectFill
        self.magicScene.backgroundColor = UIColor.blackColor()
        
        self.assignRandomMagicColor()
        self.magic.position = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame))
        self.magic.removeFromParent()
        self.magicScene.addChild(self.magic)
        self.magicView.presentScene(self.magicScene)
    }
}

class ChampionCollectionViewDataSource : NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
    private static let COLUMN_ROW_COUNT = "row_count"
    
    private var championCountProjection : [String] {
        get {
            return ["count(*) as \(ChampionCollectionViewDataSource.COLUMN_ROW_COUNT)"]
        }
    }
    
    private var championProjection : [String] {
        get {
            return [
                DataDragonDatabase.Champion.Columns.id,
                DataDragonDatabase.Champion.Columns.name,
                DataDragonDatabase.Champion.Columns.imageUrl,
                DataDragonDatabase.Champion.Columns.title
            ]
        }
    }
    
    private var championsCount = 0
    private var championCursor : Cursor! {
        willSet {
            if championCursor != nil {
                championCursor.close()
            }
        }
    }
    private let contentResolver : ContentResolver
    
    init(contentResolver : ContentResolver) {
        self.contentResolver = contentResolver
        super.init()
    }
    
    func championCountSignal() -> SignalProducer<Int, SQLError> {
        return uriChangeSignal(DataDragonDatabase.Champion.uri,
            contentResolver: self.contentResolver,
            notifyForDescendents: false,
            initialOperation: .Insert)
        .observeOn(dataDragonDatabaseScheduler)
        .promoteErrors(SQLError.self)
        .map() { (uri, operation) in
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
                    
                return cursor.moveToFirst() ? cursor.intFor(ChampionCollectionViewDataSource.COLUMN_ROW_COUNT) : 0
                    
            } catch {
                return 0
            }
        }
    }
    
    func championsSignal() -> SignalProducer<Cursor?, SQLError> {
        return uriChangeSignal(DataDragonDatabase.Champion.uri,
            contentResolver: self.contentResolver,
            notifyForDescendents: false,
            initialOperation: .Insert)
        .observeOn(dataDragonDatabaseScheduler)
        .promoteErrors(SQLError.self)
        .map() { (uri, operation) in
            do {
                return try self.contentResolver.query(DataDragonDatabase.Champion.uri,
                    projection: self.championProjection,
                    selectionArgs: nil,
                    sort: "\(DataDragonDatabase.Champion.Columns.name)")
            } catch {
                return nil
            }
        }
    }
    
    // MARK: UICollectionViewDataSource methods
    
    @objc func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.championsCount
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    @objc func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCellWithReuseIdentifier("championCell", forIndexPath: indexPath) as! ChampionCell
    }
    
    // MARK: UICollectionViewDelegate methods
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        guard self.championCursor != nil && self.championCursor.moveToPosition(indexPath.row) else {
            return
        }
        
        let championCell = cell as! ChampionCell
        championCell.championNameLabel.text = self.championCursor.stringFor(DataDragonDatabase.Champion.Columns.name)
        
        let imageURL = NSURL(string: self.championCursor.stringFor(DataDragonDatabase.Champion.Columns.imageUrl))
        let urlRequest = NSURLRequest(URL: imageURL!, cachePolicy: .ReturnCacheDataElseLoad, timeoutInterval: 30)
        championCell.championImageView.setImageWithURLRequest(urlRequest, placeholderImage: nil, success: { _, _, image in
            championCell.championImageView.image = image
            championCell.championImageView.layer.borderColor = UIColor.grayColor().colorWithAlphaComponent(0.5).CGColor
            championCell.championImageView.layer.borderWidth = 1.0
            championCell.setNeedsDisplay()
            }, failure: nil)
    }

    
}