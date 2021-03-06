//
//  SlackParser.swift
//  Slate
//
//  Created by Steven Masuch on 2015-02-07.
//  Copyright (c) 2015 Zanopan. All rights reserved.

//  The parser takes a lump of JSON and an optional SlackRequest to decide what to produce as
//  a result. If there's no ID in the top-level JSON, it figures that this came via the RTM API
//  and it wraps it up as an event (except as channel history, which is a messy use right now).
//  It does this work on an operation queue to take advantage of multitasking.

import Foundation
import SwiftyJSON

protocol SlackParserDelegate: class {
    func handleParsingResult(result: SlackResult)
}

class SlackParser {
    
    weak var delegate: SlackParserDelegate?
    let operationQueue: NSOperationQueue = NSOperationQueue()
    
    init(delegate: SlackParserDelegate?) {
        self.delegate = delegate
    }
    
    func parseResultFromRequest(json: JSON, request: SlackRequest?) {
        let parseOperation = NSBlockOperation(){ [weak self] in
            if let strongSelf = self {
                let result = parseJSONFromRequest(json, request)
                strongSelf.delegate?.handleParsingResult(result)
            }
        }
        
        operationQueue.addOperation(parseOperation)
    }
    
    func parseResult(json: JSON) {
        parseResultFromRequest(json, request: nil)
    }
}

func parseJSONFromRequest(json: JSON, request: SlackRequest?) -> SlackResult {
    
    var result: SlackResult  = SlackResult.ErrorResult("Could not parse this JSON")
    
    if let id = json["id"].string {
        
        switch id[id.startIndex] {
        case "C": // channel
            let channel = Channel(data: json)
            result = SlackResult.ChannelResult(channel)
            
        case "U": // user
            let user = User(data: json)
            result = SlackResult.UserResult(user)
            
        case "F": // file
            println("File parsed in JSON: " + json.stringValue)
            
        case "G": // group
            println("Group parsed in JSON")
            
        case "D": // IM (maybe this was originally for 'direct message'?)
            println("IM parsed in JSON")
            
        default:
            result = SlackResult.ErrorResult("Could not parse this JSON, but did get an id: " + id);
        }
        
    } else {
        
        // So this is an event, not a type, since there wasn't an id
        
        func createEvent(json: JSON) -> SlackResult {
            let (event, errorString) = Event.eventFromJSON(json)
            if let event = event {
                return SlackResult.EventResult(event)
            } else {
                return SlackResult.ErrorResult("Could not parse this JSON, but did get a type: " + json["type"].string! + ". Error: " + errorString!);
            }
        }
        
        // Is this a message?
        if let type = json["type"].string {
            switch type {
            case "message":
                let (message, errorString) = Message.messageFromJSON(json)
                if var message = message {
                    
                    // FIXME: refactor this so channel history requests get treated seperately from events
                    
                    if let actualRequest = request {
                        switch actualRequest {
                        case .ChannelHistory(let channel, _, _, _, _):
                            message.channelID = channel.id
                        default:
                            println("Request doesn't seem to have useful info to combo with this message")
                        }
                        let messageEvent = EventType.MessageEvent(message)
                        result = SlackResult.EventResult(Event(eventType: messageEvent, timestamp: Timestamp(fromString: json["ts"].string!)))
                    } else {
                        result = createEvent(json)
                    }
                    
                } else {
                    result = SlackResult.ErrorResult("Could not parse this JSON.  " + errorString!);
                }
                
            case "channel_marked":
                result = SlackResult.ChannelMarkedResult(json["channel"].string!, Timestamp(fromString:json["ts"].string!))
                
            default:
                result = createEvent(json)
            }
        }
    }
    
    return result
}