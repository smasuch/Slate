//
//  SlackParser.swift
//  MenuSlack
//
//  Created by Steven Masuch on 2015-02-07.
//  Copyright (c) 2015 Zanopan. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol SlackParserDelegate: class {
    func handleParsingResult(result: SlackResult)
}

class SlackParser {
    
    weak var delegate: SlackParserDelegate?
    let operationQueue: NSOperationQueue = NSOperationQueue()
    
    init(delegate: SlackParserDelegate) {
        self.delegate = delegate
    }
    
    func parseResultFromRequest(json: JSON, request: SlackRequest?) {
        let parseOperation = NSBlockOperation(){ [weak self] in
            let result = parseJSONFromRequest(json, request)
            if let strongSelf = self {
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
            println("File parsed in JSON")
            
        case "G": // group
            println("Group parsed in JSON")
            
        case "D": // IM (maybe this was originally for 'direct message'?)
            println("IM parsed in JSON")
            
        default:
            result = SlackResult.ErrorResult("Could not parse this JSON, but did get an id: " + id);
        }
        
    } else {
        // Is this a message?
        if let type = json["type"].string {
            switch type {
            case "message":
                let message = Message(messageJSON: json)
                if let actualRequest = request {
                    switch actualRequest {
                    case .ChannelHistory(let channel, _, _, _, _):
                        message.channelID = channel.id
                    default:
                        println("Request doesn't seem to have useful info to combo with this message")
                    }
                }
                result = SlackResult.MessageResult(message)
                
            default:
                result = SlackResult.ErrorResult("Could not parse this JSON, but did get a type: " + type);
            }
        }
    }
    
    return result
}