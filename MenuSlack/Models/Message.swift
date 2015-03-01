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
import Darwin

enum MessageSubtype {
    case None // This is expected for some plain vanilla messages
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
    
    init(text: String?,
        attributedText: NSAttributedString?,
        userID: String?,
        attachments: Array<Attachment>,
        subtype: MessageSubtype,
        hidden: Bool,
        channelID: String?,
        editedBy: String?,
        editedAt: Timestamp?) {
            self.text = text
            self.attributedText = attributedText
            self.userID = userID
            self.attachments = attachments
            self.subtype = subtype
            self.hidden = hidden
            self.channelID = channelID
            self.editedBy = editedBy
            self.editedAt = editedAt
    }
    
    static func messageFromJSON(messageJSON: JSON) -> (Message?, String?) {
        var errorMessage: String?
        
        let text = messageJSON["text"].string
        var attributedText: NSAttributedString?
        if text != nil {
            attributedText = NSAttributedString.attributedSlackString(text!)
        } else {
            attributedText = nil
        }
        
        let userID = messageJSON["user"].string
        
        var subtype = MessageSubtype.None
        
        if let subtypeString = messageJSON["subtype"].string {
            switch subtypeString {
            case "bot_message":
                subtype = .Bot(messageJSON["bot_id"].string!, messageJSON["username"].string!)
            case "me_message":
                subtype = .Me
            case "message_changed":
                let (event, eventError) = Event.eventFromJSON(messageJSON["message"])
                if event != nil {
                    subtype = MessageSubtype.Changed(event!)
                } else {
                    errorMessage = eventError
                }
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
        let hidden = messageJSON["hidden"].boolValue
        let channelID = messageJSON["channel"].string
        
        let editedBy = messageJSON["edited"]["user"].string
        var editedAt: Timestamp?
        if let editedTimeString = messageJSON["edited"]["ts"].string {
            editedAt = Timestamp(fromString: editedTimeString)
        }
        
        var attachments = [Attachment]()
        
        if let attachmentsArray = messageJSON["attachments"].array {
            println("Attachments from message:")
            for attachmentJSON in attachmentsArray {
                attachments.append(Attachment(attachmentJSON: attachmentJSON))
            }
        }
        
        let message = Message(text: text,
            attributedText: attributedText,
            userID: userID, attachments: attachments, subtype: subtype, hidden: hidden, channelID: channelID, editedBy: editedBy, editedAt: editedAt)
        
        return (message, errorMessage)
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

// Formatting constants

let SlackAttributeBoldFont = "SlackAttributeBoldFont"
let SlackAttributeItalicFont = "SlackAttributeItalicFont"
let SlackAttributeLink = "SlackAttributeLink"
let SlackAttributeUser = "SlackAttributeUser"
let SlackAttributeChannel = "SlackAttributeChannel"

extension NSAttributedString {
    
    class func attributedSlackString(string: String) -> NSAttributedString {
        // Initially formatted string
        var slackString = NSMutableAttributedString(string: string)
        
        // Bold
        slackString = slackString.stringByReplacingCapturesWithAttributes("\\*.+?\\*", attributes: [SlackAttributeBoldFont: SlackAttributeBoldFont])
        
        // Italic
        slackString = slackString.stringByReplacingCapturesWithAttributes("_.+?_", attributes: [SlackAttributeItalicFont: SlackAttributeItalicFont])
       
        // Code
        slackString = slackString.stringByReplacingCapturesWithAttributes("`.+?`", attributes: [String: String]())
        
        // Links & ! commands (so, stuff in angle brackets)
        slackString = slackString.stringByAttributingLinks()
        
        // Emoticons
        slackString = slackString.stringByReplacingColonSegmentsWithEmoji()
        
        // Escaped characters 
        slackString.mutableString.replaceOccurrencesOfString("&amp;", withString:"&", options:NSStringCompareOptions.allZeros, range: NSMakeRange(0, slackString.length))
        slackString.mutableString.replaceOccurrencesOfString("&lt;", withString:"<", options:NSStringCompareOptions.allZeros, range: NSMakeRange(0, slackString.length))
        slackString.mutableString.replaceOccurrencesOfString("&gt;", withString:">", options:NSStringCompareOptions.allZeros, range: NSMakeRange(0, slackString.length))
        
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
    
    func stringByReplacingColonSegmentsWithEmoji() -> NSMutableAttributedString {
        var replacedString = NSMutableAttributedString.init(attributedString: self)
        
        let regularExpression = NSRegularExpression.init(pattern: ":(\\S+):", options: NSRegularExpressionOptions.DotMatchesLineSeparators, error: nil)
        
        let matches = regularExpression?.matchesInString(self.string, options: NSMatchingOptions.allZeros, range: NSRange(location:0, length:self.length)) as! Array<NSTextCheckingResult>
        
        let emojiData = NSData(contentsOfFile:(NSBundle.mainBundle().pathForResource("emoji_pretty", ofType: "json")!))
        let emojiJSON = JSON(data: emojiData!)
        
        var emojiDictionary = [String: String]()
        
        for (index: String, subJson: JSON) in emojiJSON {
            if let emojiName = subJson["short_name"].string, let emojiCode = subJson["unified"].string {
                let emojiComponents = split(emojiCode, {$0 == "-"})
                var emojiString = ""
                for component in emojiComponents {
                    let numberFromComponent = strtoul(component, nil, 16)
                    if numberFromComponent != 0 {
                        emojiString.append(UnicodeScalar(UInt32(numberFromComponent)))
                        println("number: " + String(UInt32(numberFromComponent)))
                    }
                }
                println("emoji string: " + emojiString + " for name " + emojiName + ", code: " + emojiCode)
                emojiDictionary[emojiName] = emojiString
            }
        }
        
        for result : NSTextCheckingResult in matches.reverse() {
            let resultName = replacedString.attributedSubstringFromRange(result.rangeAtIndex(1)).string
            if let codeReplacement = emojiDictionary[resultName] {
                println("Found emoticon: " + NSStringFromRange(result.rangeAtIndex(1)) + ", replacing with " + codeReplacement)
                replacedString.replaceCharactersInRange(result.rangeAtIndex(0), withString: codeReplacement)
            }
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
            var linkRange = result.rangeAtIndex(1)
            var linkTextRange = result.rangeAtIndex(1)
            if (result.rangeAtIndex(2).location != NSNotFound) {
                linkTextRange = result.rangeAtIndex(2)
                linkTextRange.location += 1
                linkTextRange.length -= 1
                    // Remove the pipe
            }
            
            let linkText = replacedString.attributedSubstringFromRange(linkTextRange)
            let linkTarget = replacedString.attributedSubstringFromRange(linkRange).string as NSString
            var attributedLinkText = NSMutableAttributedString(attributedString: linkText)

            if linkTarget.hasPrefix("#C") {
                if (result.rangeAtIndex(2).location == NSNotFound) {
                    let channelID = linkTarget.substringWithRange(NSMakeRange(1, linkTarget.length - 1))
                    attributedLinkText.addAttribute(SlackAttributeChannel, value: channelID, range: NSMakeRange(0, attributedLinkText.length))
                }
            } else if linkTarget.hasPrefix("@U") {
                if (result.rangeAtIndex(2).location == NSNotFound) {
                    let userID = linkTarget.substringWithRange(NSMakeRange(1, linkTarget.length - 1))
                    attributedLinkText.addAttribute(SlackAttributeUser, value: userID, range: NSMakeRange(0, attributedLinkText.length))
                }
            } else if linkTarget.hasPrefix("!") {
                attributedLinkText.deleteCharactersInRange(NSMakeRange(0,1))
            } else {
                if let url = NSURL(string: replacedString.attributedSubstringFromRange(result.rangeAtIndex(1)).string) {
                    attributedLinkText.addAttribute(NSLinkAttributeName, value: url, range: NSMakeRange(0, attributedLinkText.length))
                    attributedLinkText.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyleSingle, range: NSMakeRange(0, attributedLinkText.length))
                    attributedLinkText.addAttribute(NSForegroundColorAttributeName, value: NSColor.blueColor(), range: NSMakeRange(0, attributedLinkText.length))
                }
            }
            
            replacedString.replaceCharactersInRange(result.range, withAttributedString:attributedLinkText)
        }
        
        return replacedString
    }
}