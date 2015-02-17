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
    var id : Int
    var fallback: String?
    var thumbURL: String?
    var thumbHeight: Int?
    var thumbWidth: Int?
    var imageWidth: Int?
    var imageHeight: Int?
    var imageURL: String?
    var color: String?
    var text: String?
    var pretext: String?
    var authorName: String?
    var authorLink: String?
    var authorIconURL: String?
    var title: String?
    var titleLink: String?
    var image: NSImage?
    var authorIcon: NSImage?
    var hasOnlyFallbackText: Bool {
        // We do assume it has the mandatory fallback text
        return  (thumbURL == nil) &&
                (imageURL == nil) &&
                (text == nil) &&
                (pretext == nil) &&
                (title == nil)
    }
    
    init(attachmentJSON: JSON) {
        fromURL = attachmentJSON["from_url"].string
        id = attachmentJSON["id"].int!
        fallback = attachmentJSON["fallback"].string
        thumbURL = attachmentJSON["thumb_url"].string
        thumbHeight = attachmentJSON["thumb_height"].int
        thumbWidth = attachmentJSON["thumb_width"].int
        imageHeight = attachmentJSON["image_height"].int
        imageWidth = attachmentJSON["image_width"].int
        imageURL = attachmentJSON["image_url"].string
        color = attachmentJSON["color"].string
        text = attachmentJSON["text"].string
        pretext = attachmentJSON["pretext"].string
        authorName = attachmentJSON["author_name"].string
        authorLink = attachmentJSON["author_link"].string
        authorIconURL = attachmentJSON["author_icon"].string
        title = attachmentJSON["title"].string
        titleLink = attachmentJSON["title_link"].string
    }
}