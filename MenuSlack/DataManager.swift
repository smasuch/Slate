//
//  DataManager.swift
//  MenuSlack
//
//  Created by Steven Masuch on 2015-01-28.
//  Copyright (c) 2015 Zanopan. All rights reserved.
//

import Foundation

class DataManager {
    var users: Dictionary<String, User>
    var currentTeamState: TeamState
    
    init() {
        users = [String: User]()
        currentTeamState = TeamState()
    }
    
    func handleEvent(event: Event){
        currentTeamState = currentTeamState.incorporateEvent(event)
    }
    
    func menuViewed() {
        currentTeamState.messagesViewed()
    }
    
    func scrubReadMessages () {
        
    }
}
