//
//  Channel.swift
//  MenuSlack
//
//  Created by Steven Masuch on 2015-01-13.
//  Copyright (c) 2015 Zanopan. All rights reserved.
//

import Foundation

class Channel {
    let messages: Array<Message>
    
    init (messages: Array<Message>) {
        self.messages = messages
    }
}
