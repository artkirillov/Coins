//
//  CoinsUITests.swift
//  CoinsUITests
//
//  Created by Artem Kirillov on 25.03.18.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import XCTest

class CoinsUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testExample() {
        
        snapshot("01")
        let app = XCUIApplication()
        let tabBar = app.tabBars
        
        app.tables.element.cells.element(boundBy: 0).tap()
        snapshot("02")
        app.buttons.element(boundBy: 0).tap()
        
        tabBar.buttons.element(boundBy: 1).tap()
        snapshot("03")
        
        app.buttons.element(boundBy: 4).tap()
        snapshot("07")
        app.buttons.element(boundBy: 1).tap()
        
        tabBar.buttons.element(boundBy: 2).tap()
        snapshot("04")
        
        tabBar.buttons.element(boundBy: 3).tap()
        snapshot("05")
        
        app.buttons.element(boundBy: 4).tap()
        snapshot("06")
    }
    
}
