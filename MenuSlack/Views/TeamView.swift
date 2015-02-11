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
        var messageViewSize = NSSize(width: 500.0, height: 10.0)
        var messageLabelOrigin = CGPoint(x: 49.0, y: 8.0)
        var userPicOrigin = CGPoint(x: 11.0, y: -30.0)
        var previousUser: User?
        
        func addUserPic(user: User) {
            let imageView = NSImageView(frame: NSRect(origin: userPicOrigin, size: CGSize(width: 24.0, height: 24.0)))
            self.addSubview(imageView)
            
            if let image = user.image48Image {
                imageView.image = image
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
                    
                    var displayText = true
                    
                    for attachment in message.attachments {
                        if let imageURL = attachment.imageURL {
                            
                            if let messageText = message.text {
                                displayText = !messageText.hasPrefix("<" + imageURL)
                            }
                            
                            let imageView = NSImageView(frame: NSRect(origin: messageLabelOrigin, size: CGSize(width: attachment.imageWidth!, height: attachment.imageHeight!)))
                            
                            if let image = attachment.image {
                                imageView.image = image
                            }
                            
                            imageView.imageScaling = NSImageScaling.ImageScaleNone;
                            imageView.animates = true;
                            
                            self.addSubview(imageView)
                            let messageViewHeightIncrease = imageView.frame.size.height + 20.0
                            messageLabelOrigin.y += messageViewHeightIncrease
                            messageViewSize.height += messageViewHeightIncrease
                            userPicOrigin.y += messageViewHeightIncrease
                        }
                    }

                    
                    previousUser = message.user
                    
                    if displayText && message.attributedText != nil {
                        
                        let messageText = message.attributedText!
                        
                        let messageLabel = NSTextField(frame: NSRect(origin: messageLabelOrigin, size: CGSize.zeroSize))
                        messageLabel.attributedStringValue = messageText
                        messageLabel.bordered = false
                        messageLabel.editable = false
                        messageLabel.frame.size = messageLabel.attributedStringValue.boundingRectWithSize(NSSize(width: messageViewSize.width - messageLabelOrigin.x - 30.0, height: 300.0), options: NSStringDrawingOptions.UsesLineFragmentOrigin).size
                        messageLabel.frame.size.width += 10.0
                        messageLabel.backgroundColor = NSColor.clearColor()
                        self.addSubview(messageLabel)
                        
                        let messageViewHeightIncrease = messageLabel.frame.size.height + 10.0;
                        messageLabelOrigin.y += messageViewHeightIncrease
                        messageViewSize.height += messageViewHeightIncrease
                        userPicOrigin.y += messageViewHeightIncrease
                    }
                    
                }
                
                // Add in the last userpic
                if let actualPreviousUser = previousUser {
                    addUserPic(actualPreviousUser)
                }
                
                // Add the channel title
                
                let gradientView = NSGradientView(frame: NSRect(x: 0.0, y: messageLabelOrigin.y, width: messageViewSize.width, height: 26.0))
                gradientView.topColor = NSColor(calibratedRed: 234.0/255.0, green: 253.0/255.0, blue: 210.0/215.0, alpha: 1.0)
                gradientView.bottomColor = NSColor(calibratedRed: 202.0/255.0, green: 250.0/255.0, blue: 179.0/255.0, alpha: 1.0)
                self.addSubview(gradientView)
                messageViewSize.height += 15.0
                
                let channelTitleView = NSTextField(frame: NSRect(x: userPicOrigin.x, y: messageLabelOrigin.y, width: messageViewSize.width, height: 26.0))
                channelTitleView.font = NSFont(name: "AvenirNext-Bold", size: 15.0)
                channelTitleView.stringValue = channel.name!
                channelTitleView.bordered = false
                channelTitleView.editable = false
                channelTitleView.backgroundColor = NSColor.clearColor()
                self.addSubview(channelTitleView)
            }
        }
        
        self.frame.size = messageViewSize
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
