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
    var channels:   Dictionary<String, Channel>
    // Messages are contained within channels
    
    init() {
        users = [String: User]()
        channels = [String: Channel]()
    }
    
    func incorporateEvent(event: Event) -> TeamState {
        if let user = event.user {
            users[user.id] = user
        }
        
        if let channel = event.channel {
            channels[channel.id] = channel
            println("channel :" + channel.id)
        }
        
        if let message = event.message {
            if let userID = message.userID {
                 message.user = users[userID]
            }
            
            if let channelID = message.channelID {
                if let channelForMessage = channels[channelID] {
                    channelForMessage.incorporateMessage(message)
                }
            }
        }
        
        return self
    }
    
    func messagesViewed() {
        // Tell the channels the messages were viewed
    }
}