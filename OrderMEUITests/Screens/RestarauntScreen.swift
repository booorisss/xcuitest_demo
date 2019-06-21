//
//  RestarauntScreen.swift
//  OrderMEUITests
//
//  Created by Maksim A Borodin on 4/27/19.
//  Copyright © 2019 Boris Gurtovoy. All rights reserved.
//

import Foundation
import XCTest

class RestarauntScreen {
    static let app = XCUIApplication()
    
    private let detectTableButton: XCUIElement = app.collectionViews.staticTexts["Detect table"]
    private let callAWaiterButton: XCUIElement = app.collectionViews.staticTexts["Call a waiter"]
    private let bringAMenuButton: XCUIElement = app.alerts["The waiter is on his way"].buttons["Bring a menu"]
    private let okButton: XCUIElement = app.alerts["Got it!"].buttons["OK"]
    
    func detectTable() {
        detectTableButton.tap()
    }
    
    func callAWaiter() {
        callAWaiterButton.tap()
    }
    
    func bringAMenu() {
        bringAMenuButton.tap()
    }
    func confirmWaiterGotIt() {
        okButton.tap()
    }
}

class RestarauntScreen1 {
    static let app = XCUIApplication()
    
    private let detectTableButton: XCUIElement = app.collectionViews.staticTexts["Detect table"]
    private let callAWaiterButton: XCUIElement = app.collectionViews.staticTexts["Call a waiter"]
    private let callAHookahManButton: XCUIElement = app.alerts["The waiter is on his way"].buttons["Call a hookah man"]
    private let okButton: XCUIElement = app.alerts["Got it!"].buttons["OK"]
    
    func detectTable() {
        detectTableButton.tap()
    }
    
    func callAWaiter() {
        callAWaiterButton.tap()
    }
    
    func callAHookahMan() {
        callAHookahManButton.tap()
    }
    func confirmWaiterGotIt() {
        okButton.tap()
    }
    
}
