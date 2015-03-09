//
//  MenuSlackTests.swift
//  MenuSlackTests
//
//  Created by Steven Masuch on 2015-01-11.
//  Copyright (c) 2015 Zanopan. All rights reserved.
//

import Cocoa
import XCTest
import SwiftyJSON

class MenuSlackTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}

class SlackParserTests: XCTestCase  {
    
    func testParseOrdinaryMessage() {
        var messageJSON = JSON(["type":"message",
            "channel":"C024GEW14",
            "user":"U03M5RUSG",
            "text":"hello",
            "ts":"1425767574.000002",
            "team":"T024GEW0Y"])
        let result = parseJSONFromRequest(messageJSON, nil)
        
    }
}
