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

class ConnectionManager: NSObject, SRWebSocketDelegate {
    
    var webSocket: SRWebSocket?
    var dataManager: DataManager?
    var stateQueue: Queue<TeamState>
    var authToken: String?
    var reconnectionTimer: NSTimer?
    
    override init() {
        stateQueue = Queue<TeamState>()
    }
    
    func initiateConnection(token: String) {
        
        // Make a fresh data manager
        dataManager = DataManager()
        
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
                        let user = User(data: subJson)
                        let event = Event(eventJSON: subJson)
                        event.user = user
                        self.dataManager?.handleEvent(event)
                    }
                    
                    // Do the same for channels
                    
                    let channels = jsonData["channels"]
                    
                    for (index: String, subJson: JSON) in channels {
                        println(subJson)
                        let channel = Channel(data: subJson)
                        println(channel.id)
                        let event = Event(eventJSON: subJson)
                        event.channel = channel
                        self.dataManager?.handleEvent(event)
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
                if let manager = self.dataManager {
                    let event = Event(eventJSON: JSON(data: resultingData))
                    manager.handleEvent(event)
                    stateQueue.addItem(manager.currentTeamState)
                }
            }
        }
    }
    
    
    
    func webSocket(webSocket: SRWebSocket!, didFailWithError error: NSError!) {
        println(error.description)
        if error.code == 57 {
            webSocket.close()
            startReconnectionTimer()
        }
    }
    
    func webSocket(webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        println(code.description)
    }
    
    func startReconnectionTimer() {
        reconnectionTimer = NSTimer.scheduledTimerWithTimeInterval(4.0, target: self, selector: "initiateConnectionWithExistingToken", userInfo: nil, repeats: true)
    }
    
    func initiateConnectionWithExistingToken() {
        if let token = authToken {
          initiateConnection(token)
        }
    }
}


