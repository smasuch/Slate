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

class SlackParserTests: XCTestCase  {
    
    func testParsingOfOrdinaryMessage() {
        var messageJSON = JSON(["type":"message",
            "channel":"C024GEW14",
            "user":"U03M5RUSG",
            "text":"hello",
            "ts":"1425767574.000002",
            "team":"T024GEW0Y"])
        let result = parseJSONFromRequest(messageJSON, nil)
        
        // This is another example of how keeping a lot of stuff as associated enums is a clumsy idea
        
        switch result {
        case .EventResult(let event):
            XCTAssert(true, "Result should be of event type")
            switch event.eventType {
            case .MessageEvent(let message):
                XCTAssert(true, "Result's event should be of message type")
                switch message.subtype {
                case .None:
                    XCTAssert(true, "Result's event's message should have no subtype")
                default:
                    XCTAssert(false, "Result's event's message should have no subtype")
                }
            default:
                XCTAssert(false, "Result's event should be of message type")
            }
        default:
            XCTAssert(false, "Result should be of event type")
        }
    }
}
