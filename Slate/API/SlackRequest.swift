//
//  SlackRequest.swift
//  Slate
//
//  Created by Steven Masuch on 2015-02-07.
//  Copyright (c) 2015 Zanopan. All rights reserved.

//  The SlackRequest embodies a request for some information from the Slack API.
//  Requests can be generated from incorporating results in the TeamState, which
//  returns requests that represent incomplete parts of the team state.

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
