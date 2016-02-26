//
// Created by Jeff Roberts on 2/24/16.
// Copyright (c) 2016 NimbleNoggin.io. All rights reserved.
//

import Foundation
import Quick
import Nimble

class LoLChampionsSpec : QuickSpec {
    var app : XCUIApplication!
    var navigationBar : XCUIElement {
        get {
            return app.navigationBars["LoL Champion Browser"]
        }
    }
    
    var navigationBarTitle : XCUIElement {
        get {
            return navigationBar.staticTexts["LoL Champion Browser"]
        }
    }
    
    var championBrowserScreen : XCUIElement {
        get {
            return navigationBar.collectionViews.elementBoundByIndex(0)
        }
    }
    
    override func spec() {
        describe("Given that I am on the LoL Champion Browser screen") {
            beforeEach {
                self.app = XCUIApplication()
                self.app.launch()
            }

            it("Then I can scroll the list of champions until I see Ziggs") {
                self.championBrowserScreen.swipeUp()
                self.championBrowserScreen.swipeUp()
                self.championBrowserScreen.swipeUp()
                self.championBrowserScreen.swipeUp()
            }
        }
    }
}
