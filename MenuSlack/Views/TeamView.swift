//
//  TeamView.swift
//  MenuSlack
//
//  Created by Steven Masuch on 2015-02-02.
//  Copyright (c) 2015 Zanopan. All rights reserved.
//

import Cocoa

class TeamView: NSView {
    
    init(teamState: TeamState) {
        
        super.init(frame: NSRect.zeroRect)
        var messageViewSize = NSSize(width: 300.0, height: 40.0)
        var messageLabelOrigin = CGPoint(x: 20.0, y: 20.0)
        
        for message in teamState.messages.reverse() {
            if let messageText = message.text {
                
                let messageLabel = NSTextField(frame: NSRect(origin: messageLabelOrigin, size: CGSize.zeroSize))
                messageLabel.stringValue = messageText
                messageLabel.bordered = false
                messageLabel.frame.size = messageLabel.attributedStringValue.size
                self.addSubview(messageLabel)
                
                let messageViewHeightIncrease = messageLabel.frame.size.height + 20.0;
                messageLabelOrigin.y += messageViewHeightIncrease
                messageViewSize.height += messageViewHeightIncrease
            }
            
            for attachment in message.attachments {
                if let imageURL = attachment.imageURL {
                    // download that image
                    let image = NSImage(contentsOfURL: NSURL(string: imageURL)!)
                    let imageView = NSImageView(frame: NSRect(origin: messageLabelOrigin, size: CGSize(width: 200.0, height: 200.0)))
                    imageView.imageScaling = NSImageScaling.ImageScaleNone;
                    imageView.animates = true;
                    imageView.image = image
                    self.addSubview(imageView)
                    let messageViewHeightIncrease = imageView.frame.size.height + 20.0
                    messageLabelOrigin.y += messageViewHeightIncrease
                    messageViewSize.height += messageViewHeightIncrease
                }
            }
    
            self.frame.size = messageViewSize
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
