//
//  ChannelEvent.swift
//  MenuSlack
//
//  Created by Steven Masuch on 2015-02-19.
//  Copyright (c) 2015 Zanopan. All rights reserved.
//

import Foundation

enum ChannelEvent {
    case ChannelMarked(String)
        // Channel ID
    case ChannelCreated(Channel)
    case ChannelJoined(Channel)
    case ChannelLeft(Channel)
    case ChannelDeleted(String)
        // Channel ID
    case ChannelRename(Channel)
    case ChannelArchive(String, String)
        // Channel ID, user ID
    case ChannelUnarchive(String, String)
        // Channel ID, user ID
    case ChannelHistoryChanged(Timestamp, Timestamp)
        // Latest, mysterious 'ts' (regular timestamp already handled in event)
}