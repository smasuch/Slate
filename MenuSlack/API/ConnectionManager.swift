//
//  ConnectionManager.swift
//  MenuSlack
//
//  Created by Steven Masuch on 2015-01-27.
//  Copyright (c) 2015 Zanopan. All rights reserved.
//

//  The connection manager makes the initial authentication request,
//  connects to the websocket, and relays all that data to the data manager.

import Foundation
import Alamofire
import SwiftyJSON

protocol SlackResultHandler: class {
    func handleResult(result: SlackResult)
}

class ConnectionManager: NSObject, SRWebSocketDelegate, SlackRequestHandler, SlackParserDelegate {
    
    var webSocket: SRWebSocket?
    var authToken: String?
    var reconnectionTimer: NSTimer?
    var parser: SlackParser?
    weak var resultHandler: SlackResultHandler?
    
    override init() {
        super.init()
        parser = SlackParser(delegate: self)
    }
    
    func initiateConnection(token: String) {
        
        authToken = token
        Alamofire.request(.POST, "https://slack.com/api/rtm.start", parameters: ["token": token]).response { (request, response, data, error) in
            println(request)
            
            if error == nil {
                self.reconnectionTimer?.invalidate()
            }
            
            
            if let finalData : NSData = data as? NSData {
                var error: AutoreleasingUnsafeMutablePointer<NSError?> = nil
                var jsonData = JSON(data: finalData)
                println(jsonData)
                
                if let websocketString : String = jsonData["url"].string{
                    self.webSocket = SRWebSocket(URLRequest: NSURLRequest(URL: NSURL(string: websocketString)!));
                    self.webSocket?.delegate = self
                    self.webSocket?.open()
                    
                    // Get the users and add those to the queue
                    
                    let users = jsonData["users"]
                    
                    for (index: String, subJson: JSON) in users {
                        self.parser?.parseResult(subJson)
                    }
                    
                    // Do the same for channels
                    
                    let channels = jsonData["channels"]
                    
                    for (index: String, subJson: JSON) in channels {
                        self.parser?.parseResult(subJson)
                    }
                }
            }
        }
    }
    
    func webSocketDidOpen(webSocket: SRWebSocket!) {
        println("Socket opened!")
    }
    
    func webSocket(webSocket: SRWebSocket!, didReceiveMessage message: AnyObject!) {
        println(message.description)
        if let eventString = message as? String {
            let jsonData = eventString.dataUsingEncoding(NSUTF8StringEncoding)
            if let resultingData = jsonData {
                parser?.parseResultFromRequest(JSON(data: resultingData), request: nil)
            }
        }
    }
    
    func webSocket(webSocket: SRWebSocket!, didFailWithError error: NSError!) {
        println(error.description)
        if error.code == 57 {
            webSocket.close()
            startReconnectionTimer()
            println("Web socket failed")
        }
    }
    
    func webSocket(webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        println("Web socket closed")
    }
    
    func startReconnectionTimer() {
        println("Started reconnection timer")
        self.reconnectionTimer?.invalidate()
        reconnectionTimer = NSTimer.scheduledTimerWithTimeInterval(4.0, target: self, selector: "initiateConnectionWithExistingToken", userInfo: nil, repeats: true)
    }
    
    func initiateConnectionWithExistingToken() {
        if let token = authToken {
            println("Initiating a connection...")
            initiateConnection(token)
        }
    }
    
    func handleRequest(request: SlackRequest) {
        switch request {
        case .ChannelHistory(let channel, let latest, let oldest, let inclusive, let count):
            
            var parameters = ["channel": channel.id, "token": authToken!]
            if latest != nil { parameters["latest"] = latest?.description }
            if oldest != nil { parameters["oldest"] = oldest?.description }
            if inclusive { parameters["inclusive"] = "1" }
            if count != nil { parameters["count"] = count!.description }
            
            Alamofire.request(.GET, "https://slack.com/api/channels.history", parameters: parameters).response { (urlRequest, response, data, error) in
                if let finalData : NSData = data as? NSData {
                    let historyJSON = JSON(data: finalData)
                    println("Results for history of channel " + parameters.description + ": " + historyJSON.dictionary!.description)
                    for (string, messageJSON) in historyJSON["messages"] {
                        self.parser?.parseResultFromRequest(messageJSON, request: request)
                    }
                }   
            }
            
        case .AttachmentImage(let channelID, let timestamp, let attachment):
            var downloadURL = attachment.imageURL
            if downloadURL == nil && attachment.thumbURL != nil {
                downloadURL = attachment.thumbURL!
            }
            
            if let urlString = downloadURL {
                Alamofire.request(.GET, urlString).response { (urlRequest, response, data, error) in
                    if let finalData : NSData = data as? NSData {
                        let imageResult = SlackResult.AttachmentImageResult(channelID, timestamp, attachment.id, NSImage(data: finalData))
                        self.resultHandler?.handleResult(imageResult)
                    }
                }
            }
            
        case .AuthorIcon(let channelID, let timestamp, let attachment):
            if let urlString = attachment.authorIconURL {
                Alamofire.request(.GET, urlString).response { (urlRequest, response, data, error) in
                    if let finalData : NSData = data as? NSData {
                        let imageResult = SlackResult.AuthorIconResult(channelID, timestamp, attachment.id, NSImage(data: finalData))
                        self.resultHandler?.handleResult(imageResult)
                    }
                }
            }
        
        case .FileThumbnail(let file):
            if let urlString = file.thumb360 {
                Alamofire.request(.GET, urlString).response { (urlRequest, response, data, error) in
                    if let finalData : NSData = data as? NSData {
                        let fileThumbnailResult = SlackResult.FileThumbnailResult(file, NSImage(data: finalData))
                        self.resultHandler?.handleResult(fileThumbnailResult)
                    }
                }
            }
            
        case .UserImage(let user, let imageKey):
                // Not actually using the image key yet...
            if let urlString = user.image48URL {
                Alamofire.request(.GET, urlString).response { (urlRequest, response, data, error) in
                    if let finalData : NSData = data as? NSData {
                        let fileThumbnailResult = SlackResult.UserImageResult(user, imageKey, NSImage(data:finalData))
                        self.resultHandler?.handleResult(fileThumbnailResult)
                    }
                }
            }
            
        case .MarkChannel(let channelID, let timestamp):
            Alamofire.request(.POST, "https://slack.com/api/channels.mark", parameters: ["token": authToken!, "channel": channelID, "ts": timestamp.description]).response{ (urlRequest, response, data, error) in
                if let finalData : NSData = data as? NSData {
                    self.parser?.parseResultFromRequest(JSON(data: finalData), request: request)
                }
            }
            
        default:
            println("Can't handle this request.")
        }
    }
    
    func handleParsingResult(result: SlackResult) {
        self.resultHandler?.handleResult(result)
    }
}