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

class DataManager: QueueObserver {
    var users: Dictionary<String, User>
    var resultQueue: Queue<SlackResult>?
    let stateQueue: Queue<TeamState>
    let changeQueue : NSOperationQueue
    weak var requestHandler: SlackRequestHandler?
    var currentTeamState: TeamState {
        didSet {
            stateQueue.addItem(currentTeamState)
        }
    }
    
    init() {
        users = [String: User]()
        currentTeamState = TeamState()
        stateQueue = Queue<TeamState>()
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
    
    func menuViewed() {
        currentTeamState.markMessagesAsRead()
    }
    
    func clearReadMessages() {
        currentTeamState.trimReadMessages()
    }
    
    func queueAddedObject() {
        if let result = resultQueue?.popTopItem() {
            incorporateResult(result)
        }
    }
}
