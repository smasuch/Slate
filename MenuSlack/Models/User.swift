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
    var id: Int
    
    init(data: JSON) {
        name = data["name"].string
        id = data["id"].intValue
    }
}