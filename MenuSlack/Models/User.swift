//
//  User.swift
//  MenuSlack
//
//  Created by Steven Masuch on 2015-01-28.
//  Copyright (c) 2015 Zanopan. All rights reserved.
//

import Foundation
import SwiftyJSON

// TODO: change to struct
class User {
    var name: String?
    var id: String
    var image24URL: String?
    var image48URL: String?
    var image48Image: NSImage?
    
    init(data: JSON) {
        name = data["name"].string
        id = data["id"].string!
        image24URL = data["profile"]["image_24"].string
        image48URL = data["profile"]["image_48"].string
    }
    
    func description() -> String {
        if let name = self.name {
            return "User " + id + ", name: " + name
        } else {
            return "User " + id + ", but no name!"
        }
    }
}

enum Presence: String {
    case Away = "away"
    case Active = "active"
}