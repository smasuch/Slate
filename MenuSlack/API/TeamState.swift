//
//  TeamState.swift
//  MenuSlack
//
//  Created by Steven Masuch on 2015-01-28.
//  Copyright (c) 2015 Zanopan. All rights reserved.
//

import Foundation

struct TeamState {
    let users:      Dictionary<String, User>
    let channels:   Array<Channel>
    let messages:   Array<Message>
    
    init(users: Dictionary<String, User>) {
        self.users = users
        self.channels = [Channel]()
        self.messages = [Message]()
    }
    
    func incorporateEvent(event: Event) -> TeamState {
        return self
    }
}