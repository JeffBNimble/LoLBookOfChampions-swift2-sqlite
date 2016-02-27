//
//  LoLBookOfChampionsUITests.swift
//  LoLBookOfChampionsUITests
//
//  Created by Jeff Roberts on 2/24/16.
//  Copyright © 2016 NimbleNoggin.io. All rights reserved.
//

import XCTest

class LoLBookOfChampionsUITests: XCTestCase {
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
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app = XCUIApplication()
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
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
