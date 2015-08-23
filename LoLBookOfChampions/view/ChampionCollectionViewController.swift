//
//  ChampionCollectionViewController.swift
//  LoLBookOfChampions
//
//  Created by Jeff Roberts on 8/16/15.
//  Copyright © 2015 NimbleNoggin.io. All rights reserved.
//

import Foundation
import CocoaLumberjackSwift
import ReactiveCocoa
import SceneKit
import SpriteKit

class ChampionCollectionViewController : UICollectionViewController, UINavigationControllerDelegate {
    var mainBundle : NSBundle!
    
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
        
        self.magicView = SKView(frame: self.view.frame)
        self.magicView.asynchronous = true
        self.view.addSubview(self.magicView)
        self.view.sendSubviewToBack(self.magicView)
        self.presentNewMagicScene = true
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