//
//  DataManager.swift
//  MenuSlack
//
//  Created by Steven Masuch on 2015-01-28.
//  Copyright (c) 2015 Zanopan. All rights reserved.
//

import Foundation

protocol SlackRequestHandler: class {
    func handleRequest(request: SlackRequest)
}

protocol TeamStateHandler: class {
    func handleTeamState(state: TeamState)
}

class DataManager: SlackResultHandler {
    let changeQueue : NSOperationQueue
    weak var requestHandler: SlackRequestHandler?
    weak var teamStateHandler: TeamStateHandler?
    var currentTeamState: TeamState {
        didSet {
            teamStateHandler?.handleTeamState(currentTeamState)
        }
    }
    
    init() {
        currentTeamState = TeamState()
        changeQueue = NSOperationQueue()
        changeQueue.maxConcurrentOperationCount = 1 // To avoid race conditions
    }
    
    func incorporateResult(result: SlackResult){
        let changeBlock = NSBlockOperation(){ [weak self] in
            if let strongSelf = self {
                let (newState, requests) = strongSelf.currentTeamState.incorporateResult(result)
                strongSelf.currentTeamState = newState
                for request in requests {
                    strongSelf.requestHandler?.handleRequest(request)
                }
            }
        }
        
        changeQueue.addOperation(changeBlock)
    }
    
    func teamViewed() {
        for channel in currentTeamState.channels.values {
            if let timestamp = channel.eventTimeline.last?.timestamp {
              requestHandler?.handleRequest(SlackRequest.MarkChannel(channel.id, timestamp))
            }
        }
    }
    
    func clearReadMessages() {
        currentTeamState.trimReadMessages()
    }
    
    func clearData() {
        changeQueue.waitUntilAllOperationsAreFinished()
        self.currentTeamState = TeamState()
    }
    
    func handleResult(result: SlackResult) {
        incorporateResult(result)
    }
}
