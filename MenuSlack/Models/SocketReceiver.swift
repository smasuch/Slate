//
//  SocketReceiver.swift
//  MenuSlack
//
//  Created by Steven Masuch on 2015-01-14.
//  Copyright (c) 2015 Zanopan. All rights reserved.
//

import Foundation

class SocketReceiver: NSObject, SRWebSocketDelegate {
    
    var URLRequest: NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: "https://slack.com/api/rtm.start")!)
    var webSocket: SRWebSocket?
    
    func webSocket(webSocket: SRWebSocket!, didReceiveMessage message: AnyObject!) {
        println(message.description)
    }
    
    func initiateConnection() {
        self.URLRequest.addValue("xoxp-2151428947-2433938776-2459009873-874a82", forHTTPHeaderField: "token")
        self.webSocket = SRWebSocket(URLRequest: self.URLRequest)
        self.webSocket?.delegate = self
        self.webSocket?.open()
    }
    
    func webSocketDidOpen(webSocket: SRWebSocket!) {
        println("Socket opened!")
    }
    
    func webSocket(webSocket: SRWebSocket!, didFailWithError error: NSError!) {
        println(error.description)
        println(error.userInfo)
    }
    
    func webSocket(webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        println(code.description)
    }

}
