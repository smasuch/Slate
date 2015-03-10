//
//  FileComment.swift
//  Slate
//
//  Created by Steven Masuch on 2015-02-11.
//  Copyright (c) 2015 Zanopan. All rights reserved.

//  FileComment represents a comment on a file.

import Foundation
import SwiftyJSON

struct FileComment {
    let id: String
    let created: Int
    let timestamp: Int
    let userID: String
    let comment: String
    
    init(commentJSON: JSON) {
        id = commentJSON["id"].string!
        created = commentJSON["created"].int!
        timestamp = commentJSON["timestamp"].int!
        userID = commentJSON["user"].string!
        comment = commentJSON["comment"].string!
    }
}