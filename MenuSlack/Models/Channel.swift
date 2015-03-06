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
    var eventTimeline: Array<Event>
    let id: String
    var lastRead: Timestamp? {
        didSet {
            if let lastReadTimestamp = lastRead {
                var prunedEvents = [Event]()
                for event in eventTimeline {
                    if event.timestamp >= lastReadTimestamp {
                        prunedEvents.append(event)
                    }
                }
                eventTimeline = prunedEvents
            }
        }
    }
    var topic: String?
    var name: String?
    var isMember: Bool
    var hasUnreadMessages: Bool {
        
        if let lastMessageTimestamp = eventTimeline.last?.timestamp {
            if let channelMark = lastRead {
                return lastMessageTimestamp > channelMark
            }
        }
        
        return false
    }
    
    init(data: JSON) {
        name = data["name"].string
        id = data["id"].string!
        topic = data["topic"]["value"].string
        if let timestampString = data["last_read"].string {
            lastRead = Timestamp(fromString: timestampString)
        }
        isMember = data["is_member"].boolValue
        eventTimeline = [Event]()
        
        let latestEventJSON = data["latest"]
        if latestEventJSON.type != .Null  {
            var modifiedLatestEventJSON = latestEventJSON
            modifiedLatestEventJSON["channel"].string = data["id"].string!
            let (event, errorMessage) = Event.eventFromJSON(modifiedLatestEventJSON)
            if let event = event {
                eventTimeline.append(event)
            } else {
                println("Could not parse latest event in channel " +  data["id"].string! + ", error: " + errorMessage!)
            }
            
        }
    }
    
    mutating func incorporateEvent(event: Event) {
        switch event.eventType  {
        case .MessageEvent(let message):
            switch message.subtype {
            case .None:  // A basic plain message
                var index = 0
                
                for existingEvent in eventTimeline {
                    if existingEvent.timestamp > event.timestamp {
                        break
                    } else if existingEvent.timestamp == event.timestamp {
                        eventTimeline.removeAtIndex(index) // remove pre-existing message, to avoid duplicate
                        break;
                    } else {
                        index++
                    }
                }
                
                eventTimeline.insert(event, atIndex: index)
            case .Changed:
                if let index = find(eventTimeline, event) {
                    let eventToReplace = eventTimeline[index]
                    var shouldReplace = true
                    switch eventToReplace.eventType {
                    case .MessageEvent(let messageToReplace):
                        if let lastEditedTimestamp = messageToReplace.editedAt {
                            shouldReplace = message.editedAt >= lastEditedTimestamp
                        }
                    default:
                        println("Yes, associated events probably weren't the best way to do this")
                    }
                    eventTimeline.removeAtIndex(index)
                    eventTimeline.insert(event, atIndex: index)
                }
            case .FileShare(let file, let sharedAtUpload):
                var index = 0
                
                for existingEvent in eventTimeline {
                    if existingEvent.timestamp > event.timestamp {
                        break
                    } else if existingEvent.timestamp == event.timestamp {
                        eventTimeline.removeAtIndex(index) // remove pre-existing message, to avoid duplicate
                        break;
                    } else {
                        index++
                    }
                }
                
                eventTimeline.insert(event, atIndex: index)
            case .Deleted(let timestamp):
                var deletedEvent : Event?
                var index = 0
                for existingEvent in eventTimeline {
                    if existingEvent.timestamp == event.timestamp {
                        deletedEvent = existingEvent
                        break
                    } else {
                        index++
                    }
                }
                if deletedEvent != nil {
                    eventTimeline.removeAtIndex(index)
                }
            case .ChannelJoin(let channelID):
                println("Channel join message received, discarded")
            case .ChannelLeave:
                println("Channel leave message received, discarded")
            case .ChannelPurpose(let purpose):
                println("Channel purpose change message received, discarded")
            default:
                println("Message event was received by channel, but not incorporated")
            }
            
        case .File(let fileEvent):
            println("File event")
            
        case .Channel(let channelEvent):
            println("Channel event")
            
        default:
            println("Event was not matched for incorporating into a channel")
            
        }
    }
    
    mutating func incorporateAttachmentImage(timestamp: Timestamp, attachmentID: Int, image: NSImage) {
        if let correspondingEvent = self.eventWithTimestamp(timestamp) {
            self.incorporateEvent(correspondingEvent.eventByIncorporatingAttachmentImage(attachmentID, image: image))
        }
    }
    
    mutating func incorporateAuthorIcon(timestamp: Timestamp, attachmentID: Int, icon: NSImage) {
        if let correspondingEvent = self.eventWithTimestamp(timestamp) {
            self.incorporateEvent(correspondingEvent.eventByIncorporatingAuthorIcon(attachmentID, icon: icon))
        }
    }
    
    mutating func incorporateFileThumbnail(file: File, thumbnail: NSImage) {
        for event in eventTimeline {
            switch event.eventType {
            case .MessageEvent(let message):
                switch message.subtype {
                case .FileShare(let oldFile, let sharedOnUpload):
                    if oldFile.id == file.id {
                        self.incorporateEvent(event.eventByIncorporatingFileThumbnail(file, thumbnail: thumbnail))
                    }
                default:
                    println("Maybe associated values weren't a good way to do this")
                }
            default:
                println("Maybe associated values weren't a good way to do this")
            }

        }
    }
    
    mutating func trimReadEvents() {
        if let lastEvent = self.eventTimeline.last {
            self.eventTimeline.removeAll(keepCapacity: false)
            self.eventTimeline.append(lastEvent)
        }
    }
    
    func eventWithTimestamp(timestamp: Timestamp) -> Event? {
        var selectedEvent: Event? = nil
        for event in eventTimeline {
            if event.timestamp == timestamp {
                selectedEvent = event
                break
            }
        }
        
        return selectedEvent
    }
    
    func indexOfEventWithTimestamp(timestamp: Timestamp) -> Int? {
        var index: Int?
        
        if let event = eventWithTimestamp(timestamp) {
            index = find(eventTimeline, event)
        }
        
        return index
    }
}
