//
//  ChannelEvent.swift
//  MenuSlack
//
//  Created by Steven Masuch on 2015-02-19.
//  Copyright (c) 2015 Zanopan. All rights reserved.

//  ChannelEvent represents events relating to things going on with channels.

import Foundation
import SwiftyJSON

enum ChannelEvent {
    case ChannelMarked(String)
        // Channel ID
    case ChannelCreated(Channel)
    case ChannelJoined(Channel)
    case ChannelLeft(String)
        // Channel ID
    case ChannelDeleted(String)
        // Channel ID
    case ChannelRename(Channel)
    case ChannelArchive(String, String)
        // Channel ID, user ID
    case ChannelUnarchive(String, String)
        // Channel ID, user ID
    case ChannelHistoryChanged(Timestamp, Timestamp)
        // Latest, mysterious 'ts' (regular timestamp already handled in event)

    init(channelEventJSON: JSON) {
        if let typeString = channelEventJSON["type"].string {
            switch typeString {
            case "channel_joined":
                self = .ChannelJoined(Channel(data: channelEventJSON["channel"]))
            case "channel_left":
                self = .ChannelLeft(channelEventJSON["channel"].string!)
            default:
                self = .ChannelMarked("NULL")
            }
        } else {
            self = .ChannelMarked("NULL")
        }
    }
}