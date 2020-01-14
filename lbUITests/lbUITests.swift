//
//  lbUITests.swift
//  lbUITests
//
//  Created by Mac-HOME on 06.01.2020.
//  Copyright © 2020 Mac-HOME. All rights reserved.
//

import XCTest

class lbUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    func testValidLoginSuccess() {
        
        let validEmail = "for@test.ru"
        let validPassword = "forTestPassword0&"
        
        let app = XCUIApplication()
        let entryLoginButton = app.buttons["Login"]
        XCTAssert(entryLoginButton.exists)
        entryLoginButton.tap()
        
        let emailTextFiels = app.textFields["Email"]
        XCTAssert(emailTextFiels.exists)
        emailTextFiels.tap()
        emailTextFiels.typeText(validEmail)
        
        let passwordTextField = app.textFields["Password"]
        XCTAssert(passwordTextField.exists)
        passwordTextField.tap()
        passwordTextField.typeText(validPassword)
        
        let loginButton = app.buttons["Login"]
        XCTAssert(loginButton.exists)
        loginButton.tap()
        
        app.tables.children(matching: .other).element(boundBy: 2).swipeDown()

    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testLaunchPerformance() {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }
}
