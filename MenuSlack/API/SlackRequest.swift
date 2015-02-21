//
//  SlackRequest.swift
//  MenuSlack
//
//  Created by Steven Masuch on 2015-02-07.
//  Copyright (c) 2015 Zanopan. All rights reserved.

import Foundation

enum SlackRequest {
    case ChannelHistory(Channel, Timestamp?, Timestamp?, Bool, Int?)
        // Channel (to get the ID), latest, oldest, inclusive, count
    case AttachmentImage(String, Timestamp, Attachment)
        // Channel ID, message timestamp, attachment
    case UserImage(User, String)
        // User (for the ID), key for the user property of the image
    case AuthorIcon(String, Timestamp, Attachment)
        // Channel ID, message timestamp, attachment
    case FileThumbnail(File)
        // File that owns that thumbnail image
    case MarkChannel(String, Timestamp)
        // Channel ID and timestamp of last event
}
