//
//  Channel.swift
//  MenuSlack
//
//  Created by Steven Masuch on 2015-01-13.
//  Copyright (c) 2015 Zanopan. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Channel {
    var messages: Array<Message>
    let id: String
    var lastRead: String?
    var topic: String?
    var name: String?
    var isMember: Bool
    
    init(data: JSON) {
        name = data["name"].string
        id = data["id"].string!
        topic = data["topic"]["value"].string
        lastRead = data["last_read"].string
        isMember = data["is_member"].boolValue
        messages = [Message]()
        
    }
    
    mutating func incorporateMessage(message: Message) {
        if let subtype = message.subtype {
            switch subtype {
            case .Changed:
                var changedMessage : Message?
                for existingMessage in messages {
                    if existingMessage.timestamp == message.submessage?.timestamp {
                        changedMessage = existingMessage
                        break
                    }
                }
                if changedMessage != nil {
                    changedMessage!.text = message.submessage?.text
                    changedMessage!.attachments = message.submessage!.attachments
                }
                
            case .Deleted:
                var deletedMessage : Message?
                var index = 0
                for existingMessage in messages {
                    if existingMessage.timestamp == message.submessage?.timestamp {
                        deletedMessage = existingMessage
                        break
                    } else {
                        index++
                    }
                }
                if deletedMessage != nil {
                    messages.removeAtIndex(index)
                }
            default:
                println("No useful subtype")
            }
        } else {
            var index = 0
            if let messageTimestamp = message.timestamp as NSString? {
                var comparisonResult: NSComparisonResult = NSComparisonResult.OrderedDescending
                for existingMessage in messages {
                    if let existingTimestamp = existingMessage.timestamp as NSString? {
                        comparisonResult = messageTimestamp.compare(existingTimestamp, options: NSStringCompareOptions.NumericSearch)
                    }
                    if comparisonResult == NSComparisonResult.OrderedAscending{
                        break
                    } else {
                        index++
                    }
                }
                messages.insert(message, atIndex: index)
            }
        }
    }
    
    mutating func trimReadMessages() {
        if let lastMessage = self.messages.last {
            self.messages.removeAll(keepCapacity: false)
            self.messages.append(lastMessage)
        }
    }
    
    func messageWithTimestamp(timestamp: String) -> Message? {
        var selectedMessage: Message? = nil
        println("looking for timestamp: " + timestamp)
        for message in messages {
            if message.timestamp == timestamp {
                selectedMessage = message
                break
            }
        }
        
        return selectedMessage
    }
}
