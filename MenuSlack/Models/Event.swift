//
//  Event.swift
//  MenuSlack
//
//  Created by Steven Masuch on 2015-02-11.
//  Copyright (c) 2015 Zanopan. All rights reserved.

//  Event represents an event from the Slack RTM API. There are several different types of events,
//  some with associated messages or files.

import Foundation
import SwiftyJSON

enum EventType {
    case Hello
    case MessageEvent(Message)
    case Channel(ChannelEvent)
    case IM(IMEvent)
    case Group(GroupEvent)
    case File(FileEvent)
    case PresenceChange(String, Presence)
    case PreferenceChange(String, String)
        // Preference name, preference value
    case UserChange(User)
    case TeamJoin(User)
    case StarChanged(Bool, Item)
        // Bool is if the time is starred (true) or not (false)
    case EmojiChanged
    case CommandsChanged
    case TeamPreferenceChanged(String, String)
        // Preference name, preference value
    case TeamRenamed(String)
        // New team name
    case TeamDomainChange(String, String)
        // URL, domain
    case EmailDomainChange(String)
        // Email domain, timestamp
    case BotAdded(User)
    case BotChanged(User)
        // Really, these two bot events could be one,
        // but I'm following the API documentation on this
    case AccountsChanged
    case TeamMigrationStarted
}

struct Event: Equatable {
    let eventType: EventType
    let timestamp: Timestamp
    
    init(eventType: EventType, timestamp: Timestamp) {
        self.eventType = eventType
        self.timestamp = timestamp
    }
    
    static func eventFromJSON(eventJSON: JSON) -> (Event?, String?) {
        var errorString: String?
        var event: Event?
        
        var timestamp = Timestamp()
        
        if let timestampString = eventJSON["message"]["ts"].string {
            // This is for message changed events
            // We just use the timestamp of the original message
            timestamp = Timestamp(fromString: timestampString)
        } else if let timestampString = eventJSON["event_ts"].string {
            timestamp = Timestamp(fromString: timestampString)
        } else if let timestampString = eventJSON["ts"].string {
            timestamp = Timestamp(fromString: timestampString)
        }
        
        var eventType: EventType?
        
        if let eventTypeString = eventJSON["type"].string {
            if eventTypeString.hasPrefix("message") {
                let (message, messageError) = Message.messageFromJSON(eventJSON)
                if message != nil {
                    eventType = .MessageEvent(message!)
                } else {
                    errorString = "Could not create event, error with message. " + messageError!
                }
                
            } else if eventTypeString.hasPrefix("hello") {
                eventType = .Hello
            } else if eventTypeString.hasPrefix("channel") {
                eventType = .Channel(ChannelEvent(channelEventJSON: eventJSON))
            // TODO: fill out all event type possibilities
            /*
            } else if eventTypeString.hasPrefix("im") {
            eventType = .IM(IMEvent(imEventJSON: eventJSON))
            } else if eventTypeString.hasPrefix("group") {
            eventType = .Group(GroupEvent(groupEventJSON: eventJSON))
            } else if eventTypeString.hasPrefix("file") {
            eventType = .File(FileEvent(fileEventJson: eventJSON))
            */
            } else {
                errorString = "Event type not recognized, found " + eventTypeString
            }
        } else {
            errorString = "No event type found."
        }
        
        if eventType != nil {
            event = Event(eventType: eventType!, timestamp: timestamp)
        }
    
        return (event, errorString)
    }
    
    func eventByIncorporatingAttachmentImage(attachmentID: Int, image: NSImage) -> Event {
        switch self.eventType {
        case .MessageEvent(var message):
            return Event(eventType: .MessageEvent(message.incorporateAttachmentImage(attachmentID, image: image)), timestamp: self.timestamp)
        default:
            return self
        }
    }
    
    func eventByIncorporatingAuthorIcon(attachmentID: Int, icon: NSImage) -> Event {
        switch self.eventType {
        case .MessageEvent(var message):
            return Event(eventType: .MessageEvent(message.incorporateAuthorIcon(attachmentID, icon: icon)), timestamp: self.timestamp)
        default:
            return self
        }
    }
    
    func eventByIncorporatingFileThumbnail(file: File, thumbnail: NSImage) -> Event {
        switch self.eventType {
        case .MessageEvent(var message):
            switch message.subtype {
            case .FileShare(let oldFile, let sharedOnUpload):
                return Event(eventType: .MessageEvent(message.incorporateFileThumbnail(file, thumbnail: thumbnail)), timestamp: self.timestamp)
            default:
                return self
            }
        default:
            return self
        }
    }
}

func ==(lhs: Event, rhs: Event) -> Bool {
    return (lhs.timestamp == rhs.timestamp)
}

struct Timestamp: Comparable, Printable {
    let time: Int
    let subTime: Int?
    var description : String {
        var string = time.description
        if subTime != nil {
            string += "." + subTime!.description
        }
        
        return string
    }

    init(fromString string: String) {
        let components = split(string, {$0 == "."})
        if let time = components[0].toInt() {
            self.time = time
        } else {
            time = 0
        }
        if let subTime = components[1].toInt() {
            self.subTime = subTime
        } else {
            self.subTime = nil
        }
    }
    
    init() {
        time = 0
        subTime = 0
    }
}

func ==(lhs: Timestamp, rhs: Timestamp) -> Bool {
    
    var theSame = false
    
    if lhs.time == rhs.time {
        if (lhs.subTime != nil) && (lhs.subTime != nil) {
            theSame = lhs.subTime == rhs.subTime
        } else {
            theSame = (lhs.subTime == nil) && (rhs.subTime == nil)
        }
    }
    
    return theSame
}

func <(lhs: Timestamp, rhs: Timestamp) -> Bool {
    
    var lessThan = lhs.time < rhs.time
    
    if lhs.time == rhs.time {
        lessThan = lhs.subTime < rhs.subTime
    }
    
    return lessThan
}


