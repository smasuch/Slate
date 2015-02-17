//
//  SlackRequest.swift
//  MenuSlack
//
//  Created by Steven Masuch on 2015-02-07.
//  Copyright (c) 2015 Zanopan. All rights reserved.
//

import Foundation

enum SlackRequest {
    case ChannelHistory(Channel, String?, String?, Bool, Int?)
        // Channel (to get the ID), latest, oldest, inclusive, count
    case AttachmentImage(Message, Attachment)
        // Message (for the message timestamp), attachment (for the URL and the attachment ID)
    case UserImage(User, String)
        // User (for the ID), key for the user property of the image
    case AuthorIcon(Message, Attachment)
        // Message for the timestamp, attachment for the URL and ID
    case FileThumbnail(File)
        // File that owns that thumbnail image
    case MarkChannel(String, String)
        // Channel ID and timestamp of last event
}
