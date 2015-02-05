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
    
    var optionsController: OptionsPanelController?

    
    override init() {
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1.0)
        connectionManager = ConnectionManager()
        stateQueue = connectionManager.stateQueue
        menu = NSMenu()
        menu.minimumWidth = 300.0
        menuItem = NSMenuItem()
        
        super.init()
        
        stateQueue.observer = self
        
        let quitMenuItem = NSMenuItem(title: "Quit", action: "terminate", keyEquivalent: "")
        quitMenuItem.target = self
        menu.addItem(quitMenuItem)
        
        let optionsMenuItem = NSMenuItem(title: "Options", action: "showOptionsPanel", keyEquivalent:"")
        optionsMenuItem.target = self
        menu.addItem(optionsMenuItem)
        
        statusItem.menu = menu
        menu.delegate = self
        statusItem.title = "Slack"
        menu.addItem(menuItem)
        
        if let savedToken = NSUserDefaults.standardUserDefaults().valueForKey("AuthToken") as String? {
            connectionManager.initiateConnection(savedToken)
        }
        
        
    }
    
    func queueAddedObject() {
        if let teamState = stateQueue.popTopItem() {
            menuItem.view = TeamView(teamState: teamState)
        }
    }
    
    func menuDidClose(menu: NSMenu) {
        connectionManager.dataManager?.menuViewed()
    }
    
    func showOptionsPanel() {
        optionsController = OptionsPanelController(windowNibName: "OptionsPanelController")
        if let savedToken = NSUserDefaults.standardUserDefaults().valueForKey("AuthToken") as String? {
            optionsController?.existingToken = savedToken
        }
        optionsController?.menuController = self
        optionsController?.showWindow(nil)
    }
    
    func changeToken(token: String) {
        menuItem.view = nil;
        NSUserDefaults.standardUserDefaults().setValue(token, forKey: "AuthToken")
        connectionManager.initiateConnection(token)
    }
}