//
//  MenuController.swift
//  MenuSlack
//
//  Created by Steven Masuch on 2015-01-29.
//  Copyright (c) 2015 Zanopan. All rights reserved.
//

import Cocoa

class MenuController: QueueObserver {
    let menu: NSMenu
    var menuItem = NSMenuItem(title: "Message", action: "terminate", keyEquivalent: "")
    var stateQueue: Queue<TeamState>? {
        willSet(newStateQueue) {
            newStateQueue?.observer = self
        }
        didSet {
            oldValue?.observer = nil
        }
    }
    
    init(menu: NSMenu) {
        self.menu = menu
        self.menu.addItem(menuItem)
    }
    
    func queueAddedObject() {
        let teamState = stateQueue?.popTopItem()
        if let messages = teamState?.messages {
            
            let messageView = NSView(frame: NSRect.zeroRect)
            var messageViewSize = NSSize(width: 300.0, height: 40.0)
            var messageLabelOrigin = CGPoint(x: 20.0, y: 20.0)
            
            for message in messages.reverse() {
                if let messageText = message.text {
                    
                    let messageLabel = NSTextField(frame: NSRect(origin: messageLabelOrigin, size: CGSize.zeroSize))
                    messageLabel.stringValue = messageText
                    messageLabel.bordered = false
                    messageLabel.frame.size = messageLabel.attributedStringValue.size
                    messageView.addSubview(messageLabel)
                    
                    let messageViewHeightIncrease = messageLabel.frame.size.height + 20.0;
                    messageLabelOrigin.y += messageViewHeightIncrease
                    messageViewSize.height += messageViewHeightIncrease
                }
            }
            
            messageView.frame.size = messageViewSize
            
            menuItem.view = messageView
        }
    }
}