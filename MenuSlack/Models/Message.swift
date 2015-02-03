//
//  Message.swift
//  MenuSlack
//
//  Created by Steven Masuch on 2015-01-28.
//  Copyright (c) 2015 Zanopan. All rights reserved.
//

import Foundation
import SwiftyJSON

enum MessageSubtype: String {
    case Bot = "bot_message"
    case Me = "me_message"
    case Changed = "message_changed"
    case Deleted = "message_deleted"
    case ChannelJoin = "channel_join"
    case ChannelLeave = "channel_leave"
    case ChannelTopic = "channel_topic"
    case ChannelPurpose = "channel_purpose"
    case ChannelName = "channel_name"
    case ChannelArchive = "channel_archive"
    case ChannelUnarchive = "channel_unarchive"
    case GroupJoin = "group_join"
    case GroupLeave = "group_leave"
    case GroupTopic = "group_topic"
    case GroupPurpose = "group_purpose"
    case GroupName = "group_name"
    case GroupArchive = "group_archive"
    case GroupUnarchive = "groupe_unarchive"
    case FileShare = "file_share"
    case FileComment = "file_comment"
    case FileMention = "file_mention"
}

class Message {
    var user: User?
    var text: String?
    var userID: String?
    var attachments: Array<Attachment>
    var subtype: MessageSubtype?
    var hidden: Bool
    var timestamp: String?
    var submessage: Message?

    init(messageJSON: JSON) {
        text = messageJSON["text"].string
        if let slackString = text {
            let attributedString = NSAttributedString.attributedSlackString(slackString)
        }
        
        userID = messageJSON["user"].string
        if let subtypeString = messageJSON["subtype"].string {
            subtype = MessageSubtype(rawValue: subtypeString)
        }
        hidden = messageJSON["hidden"].boolValue
        timestamp = messageJSON["ts"].string
        
        self.attachments = [Attachment]()
        
        if let attachments = messageJSON["attachments"].array {
            println("Attachments from message:")
            for attachmentJSON in attachments {
                self.attachments.append(Attachment(attachmentJSON: attachmentJSON))
            }
        }
        
        if messageJSON["message"].type == .Dictionary {
            submessage = Message(messageJSON: messageJSON["message"])
        }
    }
    
    func description() -> String {
        var description = "Message: "
        if let messageText = text {
            description += messageText
        }
        return description
    }
}

extension NSAttributedString {
    
    class func attributedSlackString(string: String) -> NSAttributedString {
        // Initially formatted string
        var slackString = NSAttributedString(string: string)
        
        // Bold
        slackString = slackString.stringByReplacingCapturesWithAttributes("\\*.+?\\*", attributes: [String: String]())
        
        // Italic
        slackString = slackString.stringByReplacingCapturesWithAttributes("_.+?_", attributes: [String: String]())
        
        // Code
        slackString = slackString.stringByReplacingCapturesWithAttributes("`.+?`", attributes: [String: String]())
        
        // ! commands
        
        // Links
        slackString = slackString.stringByAttributingLinks()
        
        return slackString
    }
    
    func stringByReplacingCapturesWithAttributes(regex: String, attributes: Dictionary<String, String>) -> NSMutableAttributedString {
        var replacedString = NSMutableAttributedString.init(attributedString: self)
        
        let regularExpression = NSRegularExpression.init(pattern: regex, options: NSRegularExpressionOptions.DotMatchesLineSeparators, error: nil)
        
        let start = 0
        let length = self.length
        let range = NSRange(location: start, length: length)
        let matches = regularExpression?.matchesInString(self.string, options: NSMatchingOptions.allZeros, range: range) as Array<NSTextCheckingResult>
        
        for result : NSTextCheckingResult in matches.reverse() {
            println(result)
        }
        
        return replacedString
    }
    
    func stringByAttributingLinks() -> NSMutableAttributedString
    {
        var replacedString = NSMutableAttributedString.init(attributedString: self)
        
        let regularExpression = NSRegularExpression.init(pattern: "<(.+?)(\\|.*?)?>", options: NSRegularExpressionOptions.DotMatchesLineSeparators, error: nil)
        
        let matches = regularExpression?.matchesInString(self.string, options: NSMatchingOptions.allZeros, range: NSRange(location:0, length:self.length)) as Array<NSTextCheckingResult>
        
        for result : NSTextCheckingResult in matches.reverse() {
            println(result)
        }
        
        return replacedString
    }
}