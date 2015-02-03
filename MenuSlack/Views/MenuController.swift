//
//  MenuController.swift
//  MenuSlack
//
//  Created by Steven Masuch on 2015-01-29.
//  Copyright (c) 2015 Zanopan. All rights reserved.
//

import Cocoa

class MenuController: NSObject, QueueObserver, NSMenuDelegate {
    let menu: NSMenu
    let menuItem: NSMenuItem
    var stateQueue: Queue<TeamState> {
        willSet(newStateQueue) {
            newStateQueue.observer = self
        }
        didSet {
            oldValue.observer = nil
        }
    }
    
    var statusItem: NSStatusItem
    
    var connectionManager: ConnectionManager

    
    override init() {
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1.0)
        connectionManager = ConnectionManager()
        stateQueue = connectionManager.stateQueue
        menu = NSMenu()
        menuItem = NSMenuItem()
        
        super.init()
        
        stateQueue.observer = self
        menu.addItemWithTitle("Quit", action: "terminate", keyEquivalent: "")
        statusItem.menu = menu
        menu.delegate = self
        statusItem.title = "Slack"
        menu.addItem(menuItem)
        
        connectionManager.initiateConnection()
    }
    
    func queueAddedObject() {
        if let teamState = stateQueue.popTopItem() {
            menuItem.view = TeamView(teamState: teamState)
        }
    }
    
    func menuDidClose(menu: NSMenu) {
        connectionManager.dataManager.menuViewed()
    }
}