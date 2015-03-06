//
//  Item.swift
//  MenuSlack
//
//  Created by Steven Masuch on 2015-02-19.
//  Copyright (c) 2015 Zanopan. All rights reserved.

//  Item is kind of weird, as API types go. It represents something that got starred,
//  so it could be one of several different types of things.

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
