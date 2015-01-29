//
//  Message.swift
//  MenuSlack
//
//  Created by Steven Masuch on 2015-01-28.
//  Copyright (c) 2015 Zanopan. All rights reserved.
//

import Foundation
import SwiftyJSON

class Message {
    var user: User?
    var text: String?
    var userID: String?

    init(messageJSON: JSON) {
        text = messageJSON["text"].string
        userID = messageJSON["user"].string
    }
}