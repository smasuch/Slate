//
//  Attachment.swift
//  MenuSlack
//
//  Created by Steven Masuch on 2015-01-30.
//  Copyright (c) 2015 Zanopan. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Attachment {
    var fromURL: String?
    var id : Int?
    var fallback: String?
    var thumbURL: String?
    var thumbHeight: Int?
    var thumbWidth: Int?
    var imageWidth: Int?
    var imageHeight: Int?
    var imageURL: String?
    
    init(attachmentJSON: JSON) {
        fromURL = attachmentJSON["from_URL"].string
        id = attachmentJSON["id"].int
        fallback = attachmentJSON["fallback"].string
        thumbURL = attachmentJSON["thumb_url"].string
        thumbHeight = attachmentJSON["thumb_height"].int
        thumbWidth = attachmentJSON["thumb_width"].int
        imageHeight = attachmentJSON["image_height"].int
        imageWidth = attachmentJSON["image_width"].int
        imageURL = attachmentJSON["image_url"].string
    }
}