//
//  TeamState.swift
//  MenuSlack
//
//  Created by Steven Masuch on 2015-01-28.
//  Copyright (c) 2015 Zanopan. All rights reserved.
//

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
            message.user = users[message.userID!]
            messages.append(message)
        }
        
        return self
    }
}