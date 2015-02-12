//
//  FileComment.swift
//  MenuSlack
//
//  Created by Steven Masuch on 2015-02-11.
//  Copyright (c) 2015 Zanopan. All rights reserved.
//

import Foundation
import SwiftyJSON

struct FileComment {
    let id: String
    let created: String
    let timestamp: String
    let userID: String
    let comment: String
    
    init(commentJSON: JSON) {
        id = commentJSON["id"].string!
        created = commentJSON["created"].string!
        timestamp = commentJSON["timestamp"].string!
        userID = commentJSON["userID"].string!
        comment = commentJSON["comment"].string!
    }
}