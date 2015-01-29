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

class ConnectionManager: NSObject, SRWebSocketDelegate {
    
    var webSocket: SRWebSocket?
    var eventQueue: Queue<Event>?
    
    func initiateConnection() {
        Alamofire.request(.POST, "https://slack.com/api/rtm.start", parameters: ["token": "xoxp-2151428947-2433938776-2459009873-874a82"]).response { (request, response, data, error) in
            println(request)
            println(response)
            println(error)
            
            if let finalData : NSData = data as? NSData {
                var error: AutoreleasingUnsafeMutablePointer<NSError?> = nil
                var jsonData : NSDictionary = NSJSONSerialization.JSONObjectWithData(finalData, options: NSJSONReadingOptions.MutableContainers, error: error) as NSDictionary
                println(jsonData)
                
                if let websocketString : String = jsonData["url"] as? String {
                    self.webSocket = SRWebSocket(URLRequest: NSURLRequest(URL: NSURL(string: websocketString)!));
                    self.webSocket?.delegate = self
                    self.webSocket?.open()
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
                let event = Event(eventJSON: NSJSONSerialization.JSONObjectWithData(resultingData, options: NSJSONReadingOptions.MutableContainers, error: nil))
                eventQueue?.addItem(event)
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


