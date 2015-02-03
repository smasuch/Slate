//
//  TeamState.swift
//  MenuSlack
//
//  Created by Steven Masuch on 2015-01-28.
//  Copyright (c) 2015 Zanopan. All rights reserved.
//

//  The TeamState is an object representing the

import Foundation

class TeamState {
    var users:      Dictionary<String, User>
    var channels:   Array<Channel>
    var messages:   Array<Message>
    
    init() {
        users = [String: User]()
        channels = [Channel]()
        messages = [Message]()
    }
    
    func incorporateEvent(event: Event) -> TeamState {
        if let user = event.user {
            users[user.id] = user
        }
        
        if let message = event.message {
            if let userID = message.userID {
                 message.user = users[userID]
            }
           
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
        
        for existingMessage in messages {
            println(existingMessage.text)
        }
        return self
    }
    
    func messagesViewed() {
        if messages.count > 1 {
            messages.removeRange(0..<(messages.count - 1))
        }
    }
}