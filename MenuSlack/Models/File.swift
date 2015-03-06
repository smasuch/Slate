//
//  File.swift
//  MenuSlack
//
//  Created by Steven Masuch on 2015-02-11.
//  Copyright (c) 2015 Zanopan. All rights reserved.

//  File represents a file.

import Foundation
import SwiftyJSON
import Cocoa

struct File {
    let id: String
    let created: Int
    let timestamp: Int
    let name: String
    let title: String
    let url: String
    let userID: String
    let thumb360: String?
    let thumb360Size: NSSize?
    let channels: Array<String>
    let initialComment: FileComment?
    var thumbnailImage: NSImage?
    
    init(fileJSON: JSON) {
        id = fileJSON["id"].string!
        created = fileJSON["created"].int!
        timestamp = fileJSON["timestamp"].int!
        name = fileJSON["name"].string!
        title = fileJSON["title"].string!
        url = fileJSON["url"].string!
        userID = fileJSON["user"].string!
        thumb360  = fileJSON["thumb_360"].string
        if let thumb360Width = fileJSON["thumb_360_w"].int, thumb360height = fileJSON["thumb_360_h"].int {
            thumb360Size = NSSize(width: thumb360Width, height: thumb360height)
        } else {
            thumb360Size = NSSize.zeroSize
        }
        var channelsArray = [String]()
        
        for (index: String, subJson: JSON) in fileJSON["channels"] {
            if let channelID = subJson.string {
                channelsArray.append(channelID)
            }
        }
        channels = channelsArray
        
        let commentJSON = fileJSON["initial_comment"]
        if commentJSON.type != .Null {
            initialComment = FileComment(commentJSON: commentJSON)
        } else {
            initialComment = nil
        }
        
        thumbnailImage = nil
    }
}
