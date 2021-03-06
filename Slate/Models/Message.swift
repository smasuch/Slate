//
//  Message.swift
//  Slate
//
//  Created by Steven Masuch on 2015-01-28.
//  Copyright (c) 2015 Zanopan. All rights reserved.

//  Message represents a message. There are several possible subtypes of messages.

import Foundation
import SwiftyJSON
import Cocoa
import Darwin

enum MessageSubtype {
    case None // This is expected for some plain vanilla messages
    case Bot(String, String?)
        // Bot ID, username
    case Me
    case Changed
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

struct Message {
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
        
        var message: Message?
        
        var subtype = MessageSubtype.None
        
        if let subtypeString = messageJSON["subtype"].string {
            switch subtypeString {
            case "bot_message":
                subtype = .Bot(messageJSON["bot_id"].string!, messageJSON["username"].string!)
            case "me_message":
                subtype = .Me
            case "message_changed":
                // Take most of this message's data from the nested message
                let (submessage, error) = messageFromJSON(messageJSON["message"])
                message = submessage
                message?.subtype = .Changed
                errorMessage = error
            case "message_deleted":
                subtype = .Deleted(Timestamp(fromString: messageJSON["deleted_ts"].string!))
            case "channel_join":
                subtype = .ChannelJoin(messageJSON["inviter"].string)
            case "channel_leave":
                subtype = .ChannelLeave
            case "file_share":
                subtype = .FileShare(File(fileJSON: messageJSON["file"]), messageJSON["upload"].boolValue)
                
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
                case "file_comment":
                case "file_mention":
                */
            default:
                subtype = .None
            }
        } else {
            subtype = .None
        }
        
        if message == nil {
            let text = messageJSON["text"].stringValue
            
            let attributedText = NSAttributedString.attributedSlackString(messageJSON["text"].stringValue)
            
            let userID = messageJSON["user"].string
            
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
            
            message = Message(text: text,
                attributedText: attributedText,
                userID: userID, attachments: attachments, subtype: subtype, hidden: false, channelID: "", editedBy: editedBy, editedAt: editedAt)
        }
        
        message?.hidden = messageJSON["hidden"].boolValue
        message?.channelID = messageJSON["channel"].string

        return (message, errorMessage)
    }
    
    func description() -> String {
        var description = "Message: "
        if let messageText = text {
            description += messageText
        } else {
            description += "no message text included"
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
    
    mutating func incorporateAttachmentImage(attachmentID: Int, image: NSImage) -> Message {
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
    
    mutating func incorporateAuthorIcon(attachmentID: Int, icon: NSImage) -> Message {
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
    
    mutating func incorporateFileThumbnail(file: File, thumbnail: NSImage) -> Message {
        switch subtype {
        case .FileShare(var oldFile, let sharedOnUpload):
            if oldFile.id == file.id {
                oldFile.thumbnailImage = thumbnail
                subtype = .FileShare(oldFile, sharedOnUpload)
            }
            return self
        default:
            return self
        }
    }
}

// Formatting constants

let SlackAttributeBoldFont = "SlackAttributeBoldFont"
let SlackAttributeItalicFont = "SlackAttributeItalicFont"
let SlackAttributeLink = "SlackAttributeLink"
let SlackAttributeUser = "SlackAttributeUser"
let SlackAttributeChannel = "SlackAttributeChannel"

func loadEmojiDictionary() -> [String: String] {
    return NSKeyedUnarchiver.unarchiveObjectWithFile(NSBundle.mainBundle().pathForResource("emojiDictionary", ofType: "plist")!) as! [String : String]
}

let emojiDictionary = loadEmojiDictionary()

extension NSAttributedString {
    
    class func attributedSlackString(string: NSString) -> NSAttributedString {
        // Initially formatted string
        var slackString = NSMutableAttributedString(string: string as! String)
        //println("we think we have string: " + string + "of type \(_stdlib_getTypeName(string))")

        // Bold
        slackString.replaceCapturesWithAttributes("\\*.+?\\*", attributes: [SlackAttributeBoldFont: SlackAttributeBoldFont])
        
        // Italic
        slackString.replaceCapturesWithAttributes("_.+?_", attributes: [SlackAttributeItalicFont: SlackAttributeItalicFont])
       
        // Links & ! commands (so, stuff in angle brackets)
        slackString.attributeLinks()
        
        // Emoticons
        slackString.replaceColonSegmentsWithEmoji()

        // Escaped characters 
        slackString.mutableString.replaceOccurrencesOfString("&amp;", withString:"&", options:NSStringCompareOptions.allZeros, range: NSMakeRange(0, slackString.length))
        slackString.mutableString.replaceOccurrencesOfString("&lt;", withString:"<", options:NSStringCompareOptions.allZeros, range: NSMakeRange(0, slackString.length))
        slackString.mutableString.replaceOccurrencesOfString("&gt;", withString:">", options:NSStringCompareOptions.allZeros, range: NSMakeRange(0, slackString.length))

        return slackString
    }
}

extension NSMutableAttributedString {

    func replaceCapturesWithAttributes(regex: String, attributes: Dictionary<String, AnyObject>) {
        
        let regularExpression = NSRegularExpression.init(pattern: regex, options: NSRegularExpressionOptions.DotMatchesLineSeparators, error: nil)
        
        let start = 0
        let length = self.length
        let range = NSRange(location: start, length: length)
        let matches = regularExpression?.matchesInString(self.string, options: NSMatchingOptions.allZeros, range: range) as! Array<NSTextCheckingResult>
        
        for result : NSTextCheckingResult in matches.reverse() {
            // Remove the bounding characters
            self.deleteCharactersInRange(NSRange(location: result.range.location + result.range.length - 1, length: 1))
            self.deleteCharactersInRange(NSRange(location: result.range.location, length: 1))
            self.addAttributes(attributes, range: NSRange(location: result.range.location, length: result.range.length - 2))
        }
    }
    
    func replaceColonSegmentsWithEmoji() {
        let regularExpression = NSRegularExpression.init(pattern: ":(\\S+):", options: NSRegularExpressionOptions.DotMatchesLineSeparators, error: nil)
        
        let matches = regularExpression?.matchesInString(self.string, options: NSMatchingOptions.allZeros, range: NSRange(location:0, length:self.length)) as! Array<NSTextCheckingResult>
        
        for result : NSTextCheckingResult in matches.reverse() {
            let resultName = self.attributedSubstringFromRange(result.rangeAtIndex(1)).string
            if let codeReplacement = emojiDictionary[resultName] {
                println("Found emoticon: " + NSStringFromRange(result.rangeAtIndex(1)) + ", replacing with " + codeReplacement)
                self.replaceCharactersInRange(result.rangeAtIndex(0), withString: codeReplacement)
            }
        }
    }
    
    func attributeLinks()
    {
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
            
            let linkText = self.attributedSubstringFromRange(linkTextRange)
            let linkTarget = self.attributedSubstringFromRange(linkRange).string as NSString
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
                if let url = NSURL(string: self.attributedSubstringFromRange(result.rangeAtIndex(1)).string) {
                    attributedLinkText.addAttribute(NSLinkAttributeName, value: url, range: NSMakeRange(0, attributedLinkText.length))
                    attributedLinkText.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyleSingle, range: NSMakeRange(0, attributedLinkText.length))
                    attributedLinkText.addAttribute(NSForegroundColorAttributeName, value: NSColor.blueColor(), range: NSMakeRange(0, attributedLinkText.length))
                }
            }
            
            self.replaceCharactersInRange(result.range, withAttributedString:attributedLinkText)
        }
    }
}