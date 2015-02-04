//
//  Event.swift
//  MenuSlack
//
//  Created by Steven Masuch on 2015-01-28.
//  Copyright (c) 2015 Zanopan. All rights reserved.
//

import Foundation
import SwiftyJSON

class Event {
    var eventJSON: JSON
    var user: User?
    var message: Message?
    var channel: Channel?
    
    init(eventJSON: JSON) {
        self.eventJSON = eventJSON
        
        if let type = eventJSON["type"].string {
            switch type {
                case "message":
                    self.message = Message(messageJSON: eventJSON)
                default:
                    println("We recognize no type on this event!")
            }
        }
    }
}
