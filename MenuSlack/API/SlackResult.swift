//
//  SlackResult.swift
//  MenuSlack
//
//  Created by Steven Masuch on 2015-02-07.
//  Copyright (c) 2015 Zanopan. All rights reserved.
//

import Cocoa

enum SlackResult {
    
    case EventResult(Event)
    case UserResult(User)
    case ChannelResult(Channel)
    case MessageResult(Message)
    case FileResult(File)
    case FileThumbnailResult(File, NSImage?)
    case AttachmentImageResult(Message, Attachment, NSImage?)
    case UserImageResult(User, String, NSImage?)
    case ErrorResult(String?)
}