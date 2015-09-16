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
    
    override func prepareForReuse() {
        self.championImageView.image = nil
        self.championNameLabel.text = ""
    }
}

class ChampionCollectionViewController : UICollectionViewController, UINavigationControllerDelegate {
    var dataSource : ChampionCollectionViewDataSource!
    var mainBundle : NSBundle!
    
    private var countSignal : SignalProducer<Int, NSError>!
    private var champSignal : SignalProducer<Cursor?, NSError>!
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        guard segue.identifier == "showChampionSkins" else {
            return
        }
        
        let indexPath = self.collectionView?.indexPathForCell(sender as! UICollectionViewCell)
        let viewController = segue.destinationViewController as! ChampionSkinCollectionViewController
        let cursor = self.dataSource.championCursor
        cursor.moveToPosition(indexPath!.row)
        viewController.championId = cursor.intFor(DataDragonDatabase.Champion.Columns.id)
        viewController.championName = cursor.stringFor(DataDragonDatabase.Champion.Columns.name)
        viewController.championTitle = cursor.stringFor(DataDragonDatabase.Champion.Columns.title)
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
        
        // Setup the signals, starting with the signal that fires when the initial content is available
        self.disposables.append(
            self.dataSource.getContentSignal()
                .observeOn(QueueScheduler.mainQueueScheduler)
                .start(next: { (count, cursor) in
                    self.reloadCollectionView(count, championCursor: cursor)
                })
        )

        // Now start the signal that fires when we sync new content from the API
        self.disposables.append(
            self.dataSource.contentChangedSignal()
                .observeOn(dataDragonDatabaseScheduler)
                .start(next: { (_, _) in
                     self.disposables.append(
                        self.dataSource.getContentSignal()
                            .observeOn(QueueScheduler.mainQueueScheduler)
                            .start(next: { (count, cursor) in
                                self.reloadCollectionView(count, championCursor: cursor)
                            })
                     )
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

    private func reloadCollectionView(championCount: Int, championCursor: Cursor) {
        self.dataSource.championCount = championCount
        self.dataSource.championCursor = championCursor
        self.collectionView?.reloadData()
    }
}

class ChampionCollectionViewDataSource : NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
    static let COLUMN_ROW_COUNT = "row_count"
    
    var championProjection : [String] {
        get {
            return [
                DataDragonDatabase.Champion.Columns.id,
                DataDragonDatabase.Champion.Columns.name,
                DataDragonDatabase.Champion.Columns.imageUrl,
                DataDragonDatabase.Champion.Columns.title
            ]
        }
    }
    
    var championCount = 0
    var championCursor : Cursor! {
        willSet {
            if championCursor != nil {
                championCursor.close()
            }
        }
    }
    
    var contentObservers : [ContentObserver] = []
    let contentResolver : ContentResolver
    
    init(contentResolver : ContentResolver) {
        self.contentResolver = contentResolver
        super.init()
    }

    func contentChangedSignal() -> SignalProducer<(Uri, ContentOperation), NoError> {
        return uriChangeSignal(DataDragonDatabase.Champion.uri,
                    contentResolver: self.contentResolver,
                    notifyForDescendents: false,
                    started: { contentObserver in
                        self.contentObservers.append(contentObserver)
                    })
            .startOn(dataDragonDatabaseScheduler)
    }

    func getContentSignal() -> SignalProducer<(Int, Cursor), SQLError> {
        return SignalProducer<(Int, Cursor), SQLError>() { observer, disposable in
            var count : Int!
            var cursor : Cursor!

            // Retrieve the count of champions
            self.getChampionCountAction().apply()
                .start(next: { championCount in
                    count = championCount
                })

            // Retrieve the champions cursor
            self.getChampionsAction().apply()
                .start(next: { championCursor in
                    cursor = championCursor
                })

            sendNext(observer, (count, cursor))
            sendCompleted(observer)
        }.startOn(dataDragonDatabaseScheduler)
    }
    
    // MARK: UICollectionViewDataSource methods
    
    @objc func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.championCount
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    @objc func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCellWithReuseIdentifier("championCell", forIndexPath: indexPath) as! ChampionCell
    }
    
    // MARK: UICollectionViewDelegate methods
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        guard self.championCursor != nil && self.championCursor.moveToPosition(indexPath.row) else {
            DDLogError("Unable to move cursor \(self.championCursor) to \(indexPath.row)")
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