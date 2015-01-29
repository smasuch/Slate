//
//  User.swift
//  MenuSlack
//
//  Created by Steven Masuch on 2015-01-28.
//  Copyright (c) 2015 Zanopan. All rights reserved.
//

import Foundation
import SwiftyJSON

class User {
    var name: String?
    var id: String
    
    init(data: JSON) {
        name = data["name"].string
        id = data["id"].string!
    }
    
    func description() -> String {
        if let name = self.name {
            return "User " + id + ", name: " + name
        } else {
            return "User " + id + ", but no name!"
        }
    }
}