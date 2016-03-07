//
// Created by Jeff Roberts on 2/24/16.
// Copyright (c) 2016 NimbleNoggin.io. All rights reserved.
//

import Foundation
import Quick
import Nimble
import XCTest

class LoLBookOfChampionsSmokeTestSpec : QuickSpec {
    var app : XCUIApplication!
    var navigationBar : XCUIElement {
        get {
            return app.navigationBars.element
        }
    }
    
    var navigationBarTitle : XCUIElement {
        get {
            return navigationBar.staticTexts.element
        }
    }
    
    var navigationBarBackButton : XCUIElement {
        get {
            return navigationBar.buttons.count > 1 ? navigationBar.buttons.elementBoundByIndex(0) : navigationBar.buttons.element
        }
    }
    
    var championBrowserCollectionView : XCUIElement {
        get {
            return app.collectionViews.elementBoundByIndex(0)
        }
    }
    
    var championSkinsBrowserCollectionView : XCUIElement {
        get {
            return app.collectionViews.elementBoundByIndex(1)
        }
    }
    
    override func spec() {
        describe("Given that I am using the LoL Book of Champions app") {
            beforeEach {
                self.continueAfterFailure = false
                self.app = XCUIApplication()
                self.app.launch()
            }

            context("when I am on the champion browser screen") {
                it("then I can scroll the list of champions until I see Ziggs") {
                    var done = false
                    while !done {
                        if self.isChampionVisible("Ziggs", collectionView: self.championBrowserCollectionView) {
                            done = true
                            continue
                        }
                    
                        self.app.swipeUp()
                    }
                
                    expect(self.championCell("Ziggs", collectionView:self.championBrowserCollectionView).exists).to(beTrue())
                }
            
                it("then I can tap on Annie and see Annie's skins") {
                    self.championBrowserCollectionView.staticTexts["Annie"].tap()
                    self.waitFor(self.championSkinCell("default", collectionView: self.championSkinsBrowserCollectionView))
                    expect(self.championSkinCell("default", collectionView: self.championSkinsBrowserCollectionView).exists).to(beTrue())
                }
            }
            
            context("when I am on the champion skins browser screen") {
            
                it("then I can scroll through Annie's skins") {
                    self.championBrowserCollectionView.staticTexts["Annie"].tap()
                    self.waitFor(self.championSkinCell("default", collectionView: self.championSkinsBrowserCollectionView))
                    
                    var done = false
                    while !done {
                        if self.isChampionSkinVisible("Sweetheart Annie", collectionView: self.championSkinsBrowserCollectionView) {
                            done = true
                            continue
                        }
                        
                        self.app.swipeUp()
                    }
                    
                    expect(self.championSkinCell("Sweetheart Annie", collectionView: self.championSkinsBrowserCollectionView).exists).to(beTrue())
                }
                
                it("then I can tap the back button to go back to the Champions Browser") {
                    self.championBrowserCollectionView.staticTexts["Annie"].tap()
                    self.waitFor(self.championSkinCell("default", collectionView: self.championSkinsBrowserCollectionView))
                    
                    self.navigationBarBackButton.tap()
                    self.waitFor(self.championCell("Annie", collectionView: self.championBrowserCollectionView))
                }
            }
        }
    }
    
    private func championCell(champion: String, collectionView: XCUIElement) -> XCUIElement {
        return collectionView.staticTexts[champion]
    }
    
    private func championSkinCell(skinName: String, collectionView: XCUIElement) -> XCUIElement {
        return self.app.collectionViews.staticTexts[skinName]
    }
    
    private func isChampionVisible(champion: String, collectionView: XCUIElement) -> Bool {
        return championCell(champion, collectionView: collectionView).exists
    }
    
    private func isChampionSkinVisible(skinName: String, collectionView: XCUIElement) -> Bool {
        return championSkinCell(skinName, collectionView: collectionView).exists
    }
    
    private func waitFor(element: XCUIElement) {
        self.expectationForPredicate(NSPredicate(format:"self.exists == true"), evaluatedWithObject: element, handler: nil)
        self.waitForExpectationsWithTimeout(5, handler: nil)
    }
}
