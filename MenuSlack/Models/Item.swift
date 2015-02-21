//
//  Item.swift
//  MenuSlack
//
//  Created by Steven Masuch on 2015-02-19.
//  Copyright (c) 2015 Zanopan. All rights reserved.
//

import Foundation

enum Item {
    case MessageItem(Message)
    case FileItem(File)
    case FileCommentItem(File, FileComment)
    case ChannelItem(String)
        // Channel ID
    case IMItem(String)
        // Channel ID
    case GroupItem(String)
        // Channel ID
}
