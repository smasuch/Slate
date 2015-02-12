//
//  Event.swift
//  MenuSlack
//
//  Created by Steven Masuch on 2015-02-11.
//  Copyright (c) 2015 Zanopan. All rights reserved.
//

import Foundation

enum EventContents {
    case ContainsMessage(Message)
    case ContainsFile(File)
    case ContainsChannel(Channel)
}

struct Event {
    var contents: EventContents?
    var timestamp: String?
}
