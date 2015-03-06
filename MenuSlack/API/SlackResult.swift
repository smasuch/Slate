//
//  SlackResult.swift
//  MenuSlack
//
//  Created by Steven Masuch on 2015-02-07.
//  Copyright (c) 2015 Zanopan. All rights reserved.

//  SlackResults represent some glob of information from the Slack API.

import Cocoa

enum SlackResult {
    
    case EventResult(Event)
    case UserResult(User)
    case ChannelResult(Channel)
    case ChannelMarkedResult(String, Timestamp)
    case MessageResult(Message)
    case FileResult(File)
    case FileThumbnailResult(File, NSImage?)
    case AttachmentImageResult(String, Timestamp, Int, NSImage?)
        // Channel ID, Timestamp of message, ID of attachment, Image data
    case UserImageResult(User, String, NSImage?)
    case AuthorIconResult(String, Timestamp, Int, NSImage?)
        // Channel ID, Timestamp of message, ID of attachment, Image data
    case ErrorResult(String?)
}