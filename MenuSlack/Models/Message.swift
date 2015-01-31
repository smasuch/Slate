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
        userID = messageJSON["user"].string
        if let subtypeString = messageJSON["subtype"].string {
            subtype = MessageSubtype(rawValue: subtypeString)
        }
        hidden = messageJSON["hidden"].boolValue
        timestamp = messageJSON["ts"].string
        
        self.attachments = [Attachment]()
        if let attachments = messageJSON["attachments"].array {
            for attachmentJSON: JSON in attachments {
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