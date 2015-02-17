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
                
                func labelForAttibutedString(string: NSAttributedString, width: CGFloat) -> NSTextField {
                    let label = NSTextField(frame: NSRect(origin: CGPoint.zeroPoint, size: CGSize.zeroSize))
                    label.attributedStringValue = string
                    label.bordered = false
                    label.selectable = true
                    label.allowsEditingTextAttributes = true
                    label.frame.size = string.boundingRectWithSize(NSSize(width: width - 10.0, height: 300.0), options: NSStringDrawingOptions.UsesLineFragmentOrigin).size
                    label.frame.size.width += 10.0
                    label.backgroundColor = NSColor.clearColor()
                    
                    return label
                }
                
                
                for event in channel.eventTimeline.reverse() {
                    
                    if let contents = event.contents {
                        switch contents {
                        case .ContainsMessage(let message):
                            
                            if let actualPreviousUser = previousUser {
                                if actualPreviousUser.id != message.userID {
                                    addUserPic(actualPreviousUser)
                                }
                            }
                            
                            previousUser = message.user
                            
                            // If there are attachments, sometimes the text is redundant
                            var displayText = true
                            
                            for attachment in message.attachments {
                                
                                if let fromURL = attachment.fromURL {
                                    if let messageText = message.text {
                                        displayText = !messageText.hasPrefix("<" + fromURL)
                                    }
                                }
                                
                                // Do we have anything besides the fallback text to show?
                                
                                var attachmentHeightIncrease: CGFloat = 10.0
                                
                                if attachment.hasOnlyFallbackText {
                                    // If not, display the fallback text
                                } else {
                                    // If we do, then things will get more complicated:
                                    
                                    // Do we need an image view?
                                    if (attachment.image != nil) || (attachment.imageURL != nil) || (attachment.thumbURL != nil) {
                                        
                                        var imageFrame = NSRect(origin: messageLabelOrigin, size: NSSize.zeroSize)
                                        var imageLink: String?
                                        
                                        if let imageURL = attachment.imageURL {
                                            imageFrame.size = CGSize(width: attachment.imageWidth!, height: attachment.imageHeight!)
                                            imageLink = imageURL
                                        }
                                        
                                        if let thumbURL = attachment.thumbURL {
                                            imageFrame.size = CGSize(width: attachment.thumbWidth!, height: attachment.thumbHeight!)
                                            imageLink = thumbURL
                                        }
                                        
                                        let imageView = MSImageView(frame: imageFrame)
                                        imageView.imageScaling = NSImageScaling.ImageScaleNone;
                                        imageView.animates = true;
                                        self.addSubview(imageView)
                                        attachmentHeightIncrease += imageFrame.size.height + 10.0

                                        if let image = attachment.image {
                                            imageView.image = image
                                        } else {
                                            // display a loading animation
                                        }
                                    
                                        if let imageLink = imageLink {
                                            if let messageText = message.text {
                                                displayText = displayText && !messageText.hasPrefix("<" + imageLink)
                                            }
                                            imageView.imageURL = NSURL(string:imageLink)
                                        }
                                    }
                                    
                                    if let text = attachment.text {
                                        let textLabel = labelForAttibutedString(NSAttributedString(string: text), messageViewSize.width - messageLabelOrigin.x - 30.0)
                                        textLabel.frame.origin = CGPoint(x: messageLabelOrigin.x, y: messageLabelOrigin.y + attachmentHeightIncrease)
                                        self.addSubview(textLabel)
                                        attachmentHeightIncrease += textLabel.frame.size.height + 10.0
                                    }
                                    
                                    if let pretext = attachment.pretext {
                                        let pretextLabel = labelForAttibutedString(NSAttributedString(string: pretext), messageViewSize.width - messageLabelOrigin.x - 30.0)
                                        pretextLabel.frame.origin = CGPoint(x: messageLabelOrigin.x, y: messageLabelOrigin.y + attachmentHeightIncrease)
                                        
                                        self.addSubview(pretextLabel)
                                        attachmentHeightIncrease += pretextLabel.frame.size.height + 10.0
                                    }
                                    
                                    if let title = attachment.title {
                                        let titleLabel = labelForAttibutedString(NSAttributedString(string: title), messageViewSize.width - messageLabelOrigin.x - 30.0)
                                        titleLabel.frame.origin = CGPoint(x: messageLabelOrigin.x, y: messageLabelOrigin.y + attachmentHeightIncrease)
                                        self.addSubview(titleLabel)
                                        
                                        if let titleLink = attachment.titleLink {
                                            
                                        }
                                        
                                        attachmentHeightIncrease += titleLabel.frame.size.height + 10.0
                                    }
                                    
                                    if let authorName = attachment.authorName {
                                        
                                        var authorNameOrigin = messageLabelOrigin
                                        authorNameOrigin.y += attachmentHeightIncrease
                                        
                                        if let authorIcon = attachment.authorIcon {
                                            let authorIconView = NSImageView(frame: NSRect(origin: authorNameOrigin, size: NSSize(width: 16, height: 16)))
                                            authorIconView.image = authorIcon
                                            self.addSubview(authorIconView)
                                            authorNameOrigin.x += 22.0
                                        }
                                        
                                        let authorNameLabel = labelForAttibutedString(NSAttributedString(string: authorName), messageViewSize.width - authorNameOrigin.x - 30.0)
                                        authorNameLabel.frame.origin = authorNameOrigin
                                        self.addSubview(authorNameLabel)
                                        
                                        if let authorLink = attachment.authorLink {
                                            
                                        }
                                        
                                        attachmentHeightIncrease += authorNameLabel.frame.size.height + 10.0
                                    }
                                }
                                
                                messageLabelOrigin.y += attachmentHeightIncrease
                                messageViewSize.height += attachmentHeightIncrease
                                userPicOrigin.y += attachmentHeightIncrease
                            }
                            
                            
                            if displayText && message.attributedText != nil {
                                
                                let messageText = message.attributedText!
                                
                                let messageLabel = NSTextField(frame: NSRect(origin: messageLabelOrigin, size: CGSize.zeroSize))
                                messageLabel.attributedStringValue = messageText
                                messageLabel.bordered = false
                                messageLabel.selectable = true
                                messageLabel.allowsEditingTextAttributes = true
                                messageLabel.frame.size = messageLabel.attributedStringValue.boundingRectWithSize(NSSize(width: messageViewSize.width - messageLabelOrigin.x - 30.0, height: 300.0), options: NSStringDrawingOptions.UsesLineFragmentOrigin).size
                                messageLabel.frame.size.width += 10.0
                                messageLabel.backgroundColor = NSColor.clearColor()
                                self.addSubview(messageLabel)
                                
                                let messageViewHeightIncrease = messageLabel.frame.size.height + 10.0;
                                messageLabelOrigin.y += messageViewHeightIncrease
                                messageViewSize.height += messageViewHeightIncrease
                                userPicOrigin.y += messageViewHeightIncrease
                            }

                        case .ContainsFile(let file):
                            println("Had a file to display in the view")
                            if let commentText = file.initialComment?.comment {
                                
                                let commentLabel = NSTextField(frame: NSRect(origin: messageLabelOrigin, size: CGSize.zeroSize))
                                commentLabel.stringValue = commentText
                                commentLabel.bordered = false
                                commentLabel.editable = false
                                commentLabel.frame.size = commentLabel.attributedStringValue.boundingRectWithSize(NSSize(width: messageViewSize.width - messageLabelOrigin.x - 30.0, height: 300.0), options: NSStringDrawingOptions.UsesLineFragmentOrigin).size
                                commentLabel.frame.size.width += 10.0
                                commentLabel.backgroundColor = NSColor.clearColor()
                                self.addSubview(commentLabel)
                                
                                let messageViewHeightIncrease = commentLabel.frame.size.height + 10.0;
                                messageLabelOrigin.y += messageViewHeightIncrease
                                messageViewSize.height += messageViewHeightIncrease
                                userPicOrigin.y += messageViewHeightIncrease
                            }
                            
                        default:
                            println("Had an unknown type of event to display in the view")
                        }
                    }
                }
                
                // Add in the last userpic
                if let actualPreviousUser = previousUser {
                    addUserPic(actualPreviousUser)
                }
                
                // Clear this out for the next channel
                previousUser = nil
                
                // Add the channel title
                
                let gradientView = NSGradientView(frame: NSRect(x: 0.0, y: messageLabelOrigin.y, width: messageViewSize.width, height: 26.0))
                gradientView.topColor = NSColor(calibratedRed: 234.0/255.0, green: 253.0/255.0, blue: 210.0/215.0, alpha: 1.0)
                gradientView.bottomColor = NSColor(calibratedRed: 202.0/255.0, green: 250.0/255.0, blue: 179.0/255.0, alpha: 1.0)
                self.addSubview(gradientView)
                
                let channelTitleView = NSTextField(frame: NSRect(x: userPicOrigin.x, y: messageLabelOrigin.y, width: messageViewSize.width, height: 26.0))
                channelTitleView.font = NSFont(name: "AvenirNext-Bold", size: 15.0)
                channelTitleView.stringValue = channel.name!
                channelTitleView.bordered = false
                channelTitleView.editable = false
                channelTitleView.backgroundColor = NSColor.clearColor()
                self.addSubview(channelTitleView)
                
                let messageViewHeightIncrease = gradientView.frame.size.height;
                messageLabelOrigin.y += messageViewHeightIncrease
                messageViewSize.height += messageViewHeightIncrease
                userPicOrigin.y += messageViewHeightIncrease
            }
        }
        
        self.frame.size = messageViewSize
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
