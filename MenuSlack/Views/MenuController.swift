//
//  MenuController.swift
//  MenuSlack
//
//  Created by Steven Masuch on 2015-01-29.
//  Copyright (c) 2015 Zanopan. All rights reserved.
//

import Cocoa

class MenuController: QueueObserver {
    var menu: NSMenu?
    var stateQueue: Queue<TeamState>? {
        willSet(newStateQueue) {
            newStateQueue?.observer = self
        }
        didSet {
            oldValue?.observer = nil
        }
    }
    
    init() {
        
    }
    
    func queueAddedObject() {
        let teamState = stateQueue?.popTopItem()
        if let messages = teamState?.messages {
            for message in messages {
                var messageLabel = ": "
                if let username = message.user?.name {
                    messageLabel = username + messageLabel
                }
                if let messageText = message.text {
                    messageLabel += messageText
                }
                menu?.addItemWithTitle(messageLabel, action: "terminate", keyEquivalent: "")
            }
        }
    }
}