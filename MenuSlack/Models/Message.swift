//
//  Message.swift
//  MenuSlack
//
//  Created by Steven Masuch on 2015-01-28.
//  Copyright (c) 2015 Zanopan. All rights reserved.
//

import Foundation
import SwiftyJSON
import Cocoa

enum MessageSubtype {
    case None // Unlike events, this is expected for some plain vanilla messages
    case Bot(String, String?)
        // Bot ID, username
    case Me
    case Changed(Event)
    case Deleted(Timestamp)
        // Timestamp of the deleted message
    case ChannelJoin(String?)
        // Inviter user ID
    case ChannelLeave
    case ChannelTopic(String)
        // New topic
    case ChannelPurpose(String)
        // New purpose
    case ChannelName(String, String)
        // Old name, new name
    case ChannelArchive(Array<String>)
        // Array of user ids of members
    case ChannelUnarchive
    case GroupJoin
    case GroupLeave
    case GroupTopic(String)
        // New topic
    case GroupPurpose(String)
        // New purpose
    case GroupName(String, String)
        // Old name, new name
    case GroupArchive(Array<String>)
        // Array of user ids of members
    case GroupUnarchive
    case FileShare(File, Bool)
        // File, if this share occurred at upload
    case FileCommentAdded(File, FileComment)
    case FileMention(File)
}

class Message {
    let text: String?
    let attributedText: NSAttributedString?
    let userID: String?
    var attachments: Array<Attachment>
    var subtype: MessageSubtype
    var hidden: Bool
    var channelID: String?
    var editedBy: String?
    var editedAt: Timestamp?

    init(messageJSON: JSON) {
        
        text = messageJSON["text"].string
        attributedText = NSAttributedString.attributedSlackString(messageJSON["text"].string!)
        
        userID = messageJSON["user"].string
        if let subtypeString = messageJSON["subtype"].string {
            switch subtypeString {
            case "bot_message":
                subtype = .Bot(messageJSON["bot_id"].string!, messageJSON["username"].string!)
            case "me_message":
                subtype = .Me
            case "message_changed":
                subtype = .Changed(Event(eventJSON: messageJSON["message"]))
            case "message_deleted":
                subtype = .Deleted(Timestamp(fromString: messageJSON["deleted_ts"].string!))
            case "channel_join":
                subtype = .ChannelJoin(messageJSON["inviter"].string)
            case "channel_leave":
                subtype = .ChannelLeave
            
            /* TODO: fill out all these events
            case "channel_topic":
            case "channel_purpose":
            case "channel_name":
            case "channel_archive":
            case "channel_unarchive":
            case "group_join":
            case "group_leave":
            case "group_topic":
            case "group_purpose":
            case "group_name":
            case "group_archive":
            case "group_unarchive":
            case "file_share":
            case "file_comment":
            case "file_mention":
            */
            default:
                    subtype = .None
            }
        } else {
            subtype = .None
        }
        hidden = messageJSON["hidden"].boolValue
        channelID = messageJSON["channel"].string
        
        self.attachments = [Attachment]()
        
        if let attachments = messageJSON["attachments"].array {
            println("Attachments from message:")
            for attachmentJSON in attachments {
                self.attachments.append(Attachment(attachmentJSON: attachmentJSON))
            }
        }
    }
    
    func description() -> String {
        var description = "Message: "
        if let messageText = text {
            description += messageText
        }
        return description
    }
    
    func attachmentForID(id: Int) -> (Attachment?, Int?) {
        var selectedAttachment: Attachment? = nil
        var index: Int? = 0
        for attachment in attachments {
            if attachment.id == id {
                selectedAttachment = attachment
                break
            } else {
                index!++
            }
        }
        
        if selectedAttachment == nil {
            index = nil
        }
        
        return (selectedAttachment, index)
    }
    
    func incorporateAttachmentImage(attachmentID: Int, image: NSImage) -> Message {
        var index = 0
        var chosenAttachment: Attachment?
        
        for attachment in attachments {
            if attachment.id == attachmentID {
                chosenAttachment = attachment
                break
            } else {
                index++
            }
        }
        
        if var chosenAttachment = chosenAttachment {
            chosenAttachment.image = image
            attachments.removeAtIndex(index)
            attachments.insert(chosenAttachment, atIndex: index)
        }
        
        return self
    }
    
    func incorporateAuthorIcon(attachmentID: Int, icon: NSImage) -> Message {
        var index = 0
        var chosenAttachment: Attachment?
        
        for attachment in attachments {
            if attachment.id == attachmentID {
                chosenAttachment = attachment
                break
            } else {
                index++
            }
        }
        
        if var chosenAttachment = chosenAttachment {
            chosenAttachment.authorIcon = icon
            attachments.removeAtIndex(index)
            attachments.insert(chosenAttachment, atIndex: index)
        }
        
        return self
    }
}

extension NSAttributedString {
    
    class func attributedSlackString(string: String) -> NSAttributedString {
        // Initially formatted string
        var slackString = NSMutableAttributedString(string: string)
        if let defaultFont = NSFont(name: "Lato", size: 16.0) {
            slackString.addAttribute(NSFontAttributeName, value: defaultFont, range: NSRange(location: 0, length:slackString.length))
        }
        
        // Bold
        if let boldFont = NSFont(name: "Lato-Bold", size: 16.0) {
            slackString = slackString.stringByReplacingCapturesWithAttributes("\\*.+?\\*", attributes: [NSFontAttributeName: boldFont])
        }
        
        // Italic
        if let italicFont = NSFont(name: "Lato-Italic", size: 16.0) {
             slackString = slackString.stringByReplacingCapturesWithAttributes("_.+?_", attributes: [NSFontAttributeName: italicFont])
        }
       
        
        // Code
        slackString = slackString.stringByReplacingCapturesWithAttributes("`.+?`", attributes: [String: String]())
        
        // ! commands
        
        // Links
        slackString = slackString.stringByAttributingLinks()
        
        return slackString
    }
    
    func stringByReplacingCapturesWithAttributes(regex: String, attributes: Dictionary<String, AnyObject>) -> NSMutableAttributedString {
        var replacedString = NSMutableAttributedString.init(attributedString: self)
        
        let regularExpression = NSRegularExpression.init(pattern: regex, options: NSRegularExpressionOptions.DotMatchesLineSeparators, error: nil)
        
        let start = 0
        let length = self.length
        let range = NSRange(location: start, length: length)
        let matches = regularExpression?.matchesInString(self.string, options: NSMatchingOptions.allZeros, range: range) as! Array<NSTextCheckingResult>
        
        for result : NSTextCheckingResult in matches.reverse() {
            // Remove the bounding characters
            replacedString.deleteCharactersInRange(NSRange(location: result.range.location + result.range.length - 1, length: 1))
            replacedString.deleteCharactersInRange(NSRange(location: result.range.location, length: 1))
            replacedString.addAttributes(attributes, range: NSRange(location: result.range.location, length: result.range.length - 2))
        }
        
        return replacedString
    }
    
    func stringByAttributingLinks() -> NSMutableAttributedString
    {
        var replacedString = NSMutableAttributedString.init(attributedString: self)
        
        let regularExpression = NSRegularExpression.init(pattern: "<(.+?)(\\|.*?)?>", options: NSRegularExpressionOptions.DotMatchesLineSeparators, error: nil)
        
        let matches = regularExpression?.matchesInString(self.string, options: NSMatchingOptions.allZeros, range: NSRange(location:0, length:self.length)) as! Array<NSTextCheckingResult>
        
        for result : NSTextCheckingResult in matches.reverse() {
            println("number of matches: " + result.numberOfRanges.description)
            var linkTextRange = result.rangeAtIndex(1)
            if (result.rangeAtIndex(2).location != NSNotFound) {
                linkTextRange = result.rangeAtIndex(2)
            }
            
            let linkText = replacedString.attributedSubstringFromRange(linkTextRange)
            var attributedLinkText = NSMutableAttributedString(attributedString: linkText)
            if let url = NSURL(string: replacedString.attributedSubstringFromRange(result.rangeAtIndex(1)).string) {
                attributedLinkText.addAttribute(NSLinkAttributeName, value: url, range: NSMakeRange(0, attributedLinkText.length))
                attributedLinkText.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyleSingle, range: NSMakeRange(0, attributedLinkText.length))
                attributedLinkText.addAttribute(NSForegroundColorAttributeName, value: NSColor.blueColor(), range: NSMakeRange(0, attributedLinkText.length))
            }
            replacedString.replaceCharactersInRange(result.range, withAttributedString:attributedLinkText)
        }
        
        return replacedString
    }
}