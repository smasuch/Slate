//
//  IMEvent.swift
//  Slate
//
//  Created by Steven Masuch on 2015-02-19.
//  Copyright (c) 2015 Zanopan. All rights reserved.

//  IMEvent represents events dealing with IMs.

import Foundation

enum IMEvent {
    case IMCreated(String, Channel)
        // User ID, channel
    case IMOpened(String, String)
        // User ID, channel ID
    case IMClosed(String, String)
        // User ID, channel ID
    case IMMarked(String)
        // Channel ID
    case IMHistoryChanged(Timestamp, Timestamp)
        // Latest, mysterious 'ts'
}
