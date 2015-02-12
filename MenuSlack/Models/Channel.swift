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
        eventTimeline = [Event]()
    }
    
    mutating func incorporateEvent(event: Event) {
        if let timestamp = event.timestamp {
            if let contents = event.contents {
                switch contents  {
                case .ContainsMessage(let message):
                    if let subtype = message.subtype {
                        switch subtype {
                        case .Changed:
                            var changedMessage : Message?
                            for existingEvent in eventTimeline {
                                if existingEvent.timestamp == message.submessage?.timestamp {
                                    switch existingEvent.contents! {
                                    case .ContainsMessage(let existingMessage):
                                        changedMessage = existingMessage
                                    default:
                                        println("Found an event, but not a message to change")
                                    }
                                }
                            }
                            if changedMessage != nil {
                                changedMessage!.text = message.submessage?.text
                                changedMessage!.attachments = message.submessage!.attachments
                            }
                            
                        case .Deleted:
                            var deletedEvent : Event?
                            var index = 0
                            for existingEvent in eventTimeline {
                                if existingEvent.timestamp == message.submessage?.timestamp {
                                    deletedEvent = existingEvent
                                    break
                                } else {
                                    index++
                                }
                            }
                            if deletedEvent != nil {
                                eventTimeline.removeAtIndex(index)
                            }
                        default:
                            println("No useful subtype")
                        }
                    } else {
                        var index = 0
                        if let messageTimestamp = message.timestamp as NSString? {
                            var comparisonResult: NSComparisonResult = NSComparisonResult.OrderedDescending
                            for existingEvent in eventTimeline {
                                if let existingTimestamp = existingEvent.timestamp as NSString? {
                                    comparisonResult = messageTimestamp.compare(existingTimestamp, options: NSStringCompareOptions.NumericSearch)
                                }
                                if comparisonResult == NSComparisonResult.OrderedAscending{
                                    break
                                } else {
                                    index++
                                }
                            }
                            eventTimeline.insert(event, atIndex: index)
                        }
                    }
                    
                case .ContainsFile(let file):
                    var index = 0
                    if let eventTimestamp = event.timestamp as NSString? {
                        var comparisonResult: NSComparisonResult = NSComparisonResult.OrderedDescending
                        for existingEvent in eventTimeline {
                            if let existingTimestamp = existingEvent.timestamp as NSString? {
                                comparisonResult = eventTimestamp.compare(existingTimestamp, options: NSStringCompareOptions.NumericSearch)
                            }
                            if comparisonResult == NSComparisonResult.OrderedAscending{
                                break
                            } else {
                                index++
                            }
                        }
                        eventTimeline.insert(event, atIndex: index)
                    }
                    
                case .ContainsChannel(let channel):
                    println("Channel event")
                }
            }
        }
    }
    
    mutating func trimReadEvents() {
        if let lastEvent = self.eventTimeline.last {
            self.eventTimeline.removeAll(keepCapacity: false)
            self.eventTimeline.append(lastEvent)
        }
    }
    
    func eventWithTimestamp(timestamp: String) -> Event? {
        var selectedEvent: Event? = nil
        println("looking for timestamp: " + timestamp)
        for event in eventTimeline {
            if event.timestamp == timestamp {
                selectedEvent = event
                break
            }
        }
        
        return selectedEvent
    }
    
    func messageWithTimestamp(timestamp: String) -> Message? {
        let event = eventWithTimestamp(timestamp)
        var selectedMessage: Message?
        if let contents = event?.contents {
            switch contents {
            case .ContainsMessage(let message):
                selectedMessage = message
            default:
                println("No message found for the event with that timestamp")
            }
        }
        
        return selectedMessage;
    }
}
