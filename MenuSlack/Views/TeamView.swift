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
        var messageViewSize = NSSize(width: 400.0, height: 5.0)
        var messageLabelOrigin = CGPoint(x: 49.0, y: 8.0)
        var userPicOrigin = CGPoint(x: 11.0, y: -20.0)
        var previousUserID: String?
        
        let rightMargin: CGFloat = 30.0
        let availableMessageWidth = messageViewSize.width - rightMargin - messageLabelOrigin.x
        let maximumImageHeight: CGFloat = 300.0
        
        func addUserPic(userID: String) {
            let imageView = NSImageView(frame: NSRect(origin: userPicOrigin, size: CGSize(width: 24.0, height: 24.0)))
            self.addSubview(imageView)
            
            if let image = teamState.users[userID]?.image48Image {
                imageView.image = image
            }
        }
        
        for channel in teamState.channels.values {
            if channel.isMember {
                
                func labelForAttributedString(string: NSAttributedString, width: CGFloat) -> NSTextField {
                    let label = NSTextField(frame: NSRect(origin: CGPoint.zeroPoint, size: CGSize.zeroSize))
                    label.attributedStringValue = string
                    label.bordered = false
                    label.selectable = true
                    label.editable = false
                    label.allowsEditingTextAttributes = true
                    label.frame.size = label.attributedStringValue.boundingRectWithSize(NSSize(width: width - 10.0, height: 300.0), options: NSStringDrawingOptions.UsesLineFragmentOrigin).size
                    label.frame.size.width += 10.0
                    
                    label.backgroundColor = NSColor.clearColor()
                    
                    return label
                }
                
                func visuallyFormattedSlackString(string: NSAttributedString, withFontSize fontSize: CGFloat) -> NSAttributedString {
                    
                    var slackString = NSMutableAttributedString(attributedString: string)
                    
                    let paragraphStyles = NSMutableParagraphStyle()
                    paragraphStyles.lineSpacing = 1.0
                    paragraphStyles.maximumLineHeight = fontSize + 2.0
                    
                    
                    slackString.addAttribute(NSFontAttributeName, value: NSFont(name: "Lato", size: fontSize)!, range:NSMakeRange(0, slackString.length))
                    slackString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyles, range:NSMakeRange(0, slackString.length))
                    
                    slackString.enumerateAttribute(SlackAttributeUser, inRange: NSMakeRange(0, slackString.length), options: NSAttributedStringEnumerationOptions.Reverse, usingBlock: {attribute, range, stop in
                        
                        if attribute != nil {
                            let userID = attribute as! String
                            
                            if let user = teamState.users[userID], let username = user.name {
                                slackString.replaceCharactersInRange(range, withString: username)
                            }
                        }
                        
                    })
                    
                    slackString.enumerateAttribute(SlackAttributeChannel, inRange: NSMakeRange(0, slackString.length), options: NSAttributedStringEnumerationOptions.Reverse, usingBlock: {attribute, range, stop in
                        
                        if attribute != nil {
                            let channelID = attribute as! String
                            
                            if let channel = teamState.channels[channelID], let channelName = channel.name {
                                slackString.replaceCharactersInRange(range, withString: channelName)
                            }
                        }
                        
                    })
                    
                    slackString.enumerateAttributesInRange(NSMakeRange(0, slackString.length), options:NSAttributedStringEnumerationOptions.LongestEffectiveRangeNotRequired, usingBlock:
                        {attribute, range, stop in
                            
                            let attributesDictionary = attribute as Dictionary
                            
                            if attributesDictionary[SlackAttributeBoldFont] != nil {
                                slackString.addAttribute(NSFontAttributeName, value: NSFont(name: "Lato-Bold", size: fontSize)!, range: range)
                            }
                            
                            if attributesDictionary[SlackAttributeItalicFont] != nil {
                                slackString.addAttribute(NSFontAttributeName, value: NSFont(name: "Lato-Italic", size: fontSize)!, range: range)
                            }
                        })
                    
                    return slackString
                }
                
                
                for event in channel.eventTimeline.reverse() {
                    switch event.eventType {
                    case .MessageEvent(let message):
                        
                        if let actualPreviousUser = previousUserID {
                            if actualPreviousUser != message.userID {
                                addUserPic(actualPreviousUser)
                            }
                        }
                        
                        previousUserID = message.userID
                        
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
                                        var imageFrameSize = CGSize(width: attachment.imageWidth!, height: attachment.imageHeight!)
                                        
                                        if imageFrameSize.width > availableMessageWidth {
                                            let reductionRatio = availableMessageWidth / imageFrameSize.width
                                            imageFrameSize.width = floor(imageFrameSize.width * reductionRatio)
                                            imageFrameSize.height = floor(imageFrameSize.height * reductionRatio)
                                        }
                                        
                                        if imageFrameSize.height > maximumImageHeight {
                                            let reductionRatio = maximumImageHeight / imageFrameSize.height
                                            imageFrameSize.width = floor(imageFrameSize.width * reductionRatio)
                                            imageFrameSize.height = floor(imageFrameSize.height * reductionRatio)
                                        }
                                        
                                        imageFrame.size = imageFrameSize
                                        imageLink = imageURL
                                    }
                                    
                                    if let thumbURL = attachment.thumbURL {
                                        imageFrame.size = CGSize(width: attachment.thumbWidth!, height: attachment.thumbHeight!)
                                        imageLink = thumbURL
                                    }
                                    
                                    let imageView = MSImageView(frame: imageFrame)
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
                                
                                let smallTextParagraphStyles = NSMutableParagraphStyle()
                                smallTextParagraphStyles.lineSpacing = 1.0
                                smallTextParagraphStyles.maximumLineHeight = 16.0
                                
                                let smallTextAttributes = [NSFontAttributeName: NSFont(name: "AvenirNext-Medium", size: 13.0)!, NSParagraphStyleAttributeName: smallTextParagraphStyles]
                                
                                if let text = attachment.text {
                                    let textLabel = labelForAttributedString(NSAttributedString(string: text, attributes:smallTextAttributes), messageViewSize.width - messageLabelOrigin.x - 30.0)
                                    textLabel.frame.origin = CGPoint(x: messageLabelOrigin.x, y: messageLabelOrigin.y + attachmentHeightIncrease)
                                    self.addSubview(textLabel)
                                    attachmentHeightIncrease += textLabel.frame.size.height + 10.0
                                }
                                
                                if let pretext = attachment.pretext {
                                    let pretextLabel = labelForAttributedString(NSAttributedString(string: pretext, attributes:smallTextAttributes), messageViewSize.width - messageLabelOrigin.x - 30.0)
                                    pretextLabel.frame.origin = CGPoint(x: messageLabelOrigin.x, y: messageLabelOrigin.y + attachmentHeightIncrease)
                                    
                                    self.addSubview(pretextLabel)
                                    attachmentHeightIncrease += pretextLabel.frame.size.height + 10.0
                                }
                                
                                if let title = attachment.title {
                                    let titleLabel = labelForAttributedString(NSAttributedString(string: title, attributes:smallTextAttributes), messageViewSize.width - messageLabelOrigin.x - 30.0)
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
                                    
                                    let authorNameLabel = labelForAttributedString(NSAttributedString(string: authorName, attributes:smallTextAttributes), messageViewSize.width - authorNameOrigin.x - 30.0)
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
                            
                            let messageText = visuallyFormattedSlackString(message.attributedText!, withFontSize: 16)
                            
                            let messageLabel = NSTextField(frame: NSRect(origin: messageLabelOrigin, size: CGSize.zeroSize))
                            messageLabel.attributedStringValue = messageText
                            messageLabel.bordered = false
                            messageLabel.selectable = true
                            messageLabel.allowsEditingTextAttributes = true
                            messageLabel.frame.size = messageLabel.attributedStringValue.boundingRectWithSize(NSSize(width: messageViewSize.width - messageLabelOrigin.x - 30.0, height: 300.0), options: NSStringDrawingOptions.UsesLineFragmentOrigin).size
                            messageLabel.frame.size.width += 10.0
                            messageLabel.backgroundColor = NSColor.clearColor()
                            if event.timestamp < channel.lastRead {
                                messageLabel.alphaValue = 0.5
                            }
                            self.addSubview(messageLabel)
                            
                            let messageViewHeightIncrease = messageLabel.frame.size.height + 8.0;
                            messageLabelOrigin.y += messageViewHeightIncrease
                            messageViewSize.height += messageViewHeightIncrease
                            userPicOrigin.y += messageViewHeightIncrease
                        }

                    case .File(let fileEvent):
                        switch fileEvent {
                        case .FileShared(let file):
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
                            println("Had a file event to display in the view, but no way to incorporate it")
                        }
                        
                    default:
                        println("Had an unknown type of event to display in the view")
                    }
                }
                
                // Add in the last userpic
                if let actualPreviousUser = previousUserID {
                    addUserPic(actualPreviousUser)
                }
                
                // Clear this out for the next channel
                previousUserID = nil
                
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
                
                let messageViewHeightIncrease = gradientView.frame.size.height + 7.0;
                messageLabelOrigin.y += messageViewHeightIncrease
                messageViewSize.height += messageViewHeightIncrease
                userPicOrigin.y += messageViewHeightIncrease
            }
        }
        
        messageViewSize.height -= 10.0
        
        self.frame.size = messageViewSize
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
