//
//  LoLBookOfChampionsSmokeTests.swift
//  LoLBookOfChampionsUITests
//
//  Created by Jeff Roberts on 2/24/16.
//  Copyright © 2016 NimbleNoggin.io. All rights reserved.
//

import XCTest

class LoLBookOfChampionsSmokeTests: XCTestCase {
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
        
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func test_onChampionBrowser_canScrollToASpecificChampion() {
        var done = false
        while !done {
            if self.isChampionVisible("Ziggs", collectionView: self.championBrowserCollectionView) {
                done = true
                continue
            }
            
            self.app.swipeUp()
        }
        
        XCTAssertTrue(self.championCell("Ziggs", collectionView:self.championBrowserCollectionView).exists)
    }
    
    func test_onChampionBrowser_canTapChampionToSeeSkins() {
        self.championBrowserCollectionView.staticTexts["Annie"].tap()
        self.waitFor(self.championSkinCell("default", collectionView: self.championSkinsBrowserCollectionView))
        XCTAssertTrue(self.championSkinCell("default", collectionView: self.championSkinsBrowserCollectionView).exists)
    }
    
    func test_onChampionSkinBrowser_canScrollThroughSkins() {
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
        
        XCTAssertTrue(self.championSkinCell("Sweetheart Annie", collectionView: self.championSkinsBrowserCollectionView).exists)
    }
    
    func test_onChampionSkinBrowser_canTapBackButtonToReturnToChampionBrowser() {
        self.championBrowserCollectionView.staticTexts["Annie"].tap()
        self.waitFor(self.championSkinCell("default", collectionView: self.championSkinsBrowserCollectionView))
        
        self.navigationBarBackButton.tap()
        self.waitFor(self.championCell("Annie", collectionView: self.championBrowserCollectionView))
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
