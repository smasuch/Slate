//
//  GroupEvent.swift
//  MenuSlack
//
//  Created by Steven Masuch on 2015-02-19.
//  Copyright (c) 2015 Zanopan. All rights reserved.
//

import Foundation

enum GroupEvent {
    case GroupJoined(Channel)
    case GroupLeft(Channel)
    case GroupOpen(String, String)
        // User ID, Channel ID
    case GroupClose(String, String)
        // User ID, Channel ID
    case GroupArchive(String)
        // Channel ID
    case GroupUnarchive(String)
        // Channel ID
    case GroupRename(Channel)
    case GroupMarked(String)
        // Channel ID
    case GroupHistoryChanged(Timestamp, Timestamp)
        // Latest, mysterious 'ts'
}
