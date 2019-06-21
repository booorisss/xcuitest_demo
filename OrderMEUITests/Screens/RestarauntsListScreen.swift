//
//  RestarauntsListScreen.swift
//  OrderMEUITests
//
//  Created by Maksim A Borodin on 4/27/19.
//  Copyright © 2019 Boris Gurtovoy. All rights reserved.
//

import Foundation
import XCTest

class RestarauntsListScreen {
    static let app = XCUIApplication()
    
    private let republiqueRestaraunt: XCUIElement = app.tables.staticTexts["Republique"]
    
    func openRepublique() {
        republiqueRestaraunt.tap()
    }
    
}

class RestarauntsListScreen1 {
    static let app = XCUIApplication()
    
    private let hakkasanRestaraunt: XCUIElement = app.tables.staticTexts["Hakkasan"]
    
    func openHakkasan() {
        hakkasanRestaraunt.tap()
    }
    
}
