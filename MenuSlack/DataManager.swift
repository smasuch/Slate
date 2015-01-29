//
//  DataManager.swift
//  MenuSlack
//
//  Created by Steven Masuch on 2015-01-28.
//  Copyright (c) 2015 Zanopan. All rights reserved.
//

import Foundation

class DataManager: QueueObserver {
    var users: Dictionary<String, User>
    var eventQueue: Queue<Event>? {
        willSet(newEventQueue) {
            newEventQueue?.observer = self
        }
        didSet {
            oldValue?.observer = nil
        }
    }
    var stateQueue: Queue<TeamState>?
    var currentTeamState: TeamState
    
    init() {
        users = [String: User]()
        currentTeamState = TeamState()
    }
    
    func queueAddedObject() {
        while (eventQueue?.isEmpty() != true) {
            if let event = eventQueue?.popTopItem() {
                println(event.eventJSON.description)
                currentTeamState = currentTeamState.incorporateEvent(event)
            }
        }
        
        stateQueue?.addItem(currentTeamState)
    }   
}
