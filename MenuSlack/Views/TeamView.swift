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
        var messageViewSize = NSSize(width: 500.0, height: 40.0)
        var messageLabelOrigin = CGPoint(x: 60.0, y: 20.0)
        var userPicOrigin = CGPoint(x: 20.0, y: 20.0)
        var previousUser: User?
        
        func addUserPic(user: User) {
            let imageView = NSImageView(frame: NSRect(origin: userPicOrigin, size: CGSize(width: 24.0, height: 24.0)))
            self.addSubview(imageView)
            
            if let imageURLString = user.image24URL {
                if let imageURL = NSURL(string:imageURLString) {
                    imageView.image = NSImage(contentsOfURL: imageURL)
                }
            }
        }
        
        for channel in teamState.channels.values {
            if channel.isMember {
                for message in channel.messages.reverse() {
                    
                    if let actualPreviousUser = previousUser {
                        if actualPreviousUser.id != message.userID {
                            addUserPic(actualPreviousUser)
                        }
                    }
                    
                    previousUser = message.user
                    
                    if let messageText = message.text {
                        
                        let messageLabel = NSTextField(frame: NSRect(origin: messageLabelOrigin, size: CGSize.zeroSize))
                        messageLabel.stringValue = messageText
                        messageLabel.font = NSFont(name: "Lato", size: 16.0)
                        messageLabel.bordered = false
                        messageLabel.frame.size = messageLabel.attributedStringValue.boundingRectWithSize(NSSize(width: messageViewSize.width - messageLabelOrigin.x - 30.0, height: 300.0), options: NSStringDrawingOptions.UsesLineFragmentOrigin).size
                        messageLabel.frame.size.width += 10.0
                        self.addSubview(messageLabel)
                        
                        let messageViewHeightIncrease = messageLabel.frame.size.height + 20.0;
                        messageLabelOrigin.y += messageViewHeightIncrease
                        messageViewSize.height += messageViewHeightIncrease
                        userPicOrigin.y += messageViewHeightIncrease - 54.0
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
                    
                }
                
                // Add in the last userpic
                if let actualPreviousUser = previousUser {
                    addUserPic(actualPreviousUser)
                }
            }
        }
        
        self.frame.size = messageViewSize
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
