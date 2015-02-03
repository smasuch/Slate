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
    let dataManager: DataManager
    var stateQueue: Queue<TeamState>
    
    override init() {
        dataManager = DataManager()
        stateQueue = Queue<TeamState>()
    }
    
    func initiateConnection() {
        Alamofire.request(.POST, "https://slack.com/api/rtm.start", parameters: ["token": "xoxp-2152506032-2152506034-3552581508-c06294"]).response { (request, response, data, error) in
            println(request)
            println(response)
            println(error)
            
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
                        self.dataManager.handleEvent(event)
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
                let event = Event(eventJSON: JSON(data: resultingData))
                dataManager.handleEvent(event)
                stateQueue.addItem(dataManager.currentTeamState)
            }
        }
    }
    
    func webSocket(webSocket: SRWebSocket!, didFailWithError error: NSError!) {
        println(error.description)
        println(error.userInfo)
    }
    
    func webSocket(webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        println(code.description)
    }
    
}


