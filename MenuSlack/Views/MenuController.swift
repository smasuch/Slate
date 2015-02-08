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
    var statusItem: NSStatusItem
    var connectionManager: ConnectionManager
    var dataManager: DataManager
    var optionsController: OptionsPanelController?
    var stateQueue: Queue<TeamState> {
        willSet(newStateQueue) {
            newStateQueue.observer = self
        }
        didSet {
            oldValue.observer = nil
        }
    }

    
    override init() {
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-2.0)
        connectionManager = ConnectionManager()
        dataManager = DataManager()
        
        dataManager.resultQueue = connectionManager.resultQueue
        connectionManager.resultQueue.observer = dataManager
        dataManager.requestHandler = connectionManager
        
        stateQueue = dataManager.stateQueue
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
        statusItem.image = NSImage(named: "icon-white")
        menu.addItem(menuItem)
        
        if let savedToken = NSUserDefaults.standardUserDefaults().valueForKey("AuthToken") as String? {
            connectionManager.initiateConnection(savedToken)
        }
        
        
    }
    
    func queueAddedObject() {
        if let teamState = stateQueue.popTopItem() {
            dispatch_async(dispatch_get_main_queue()) {
                self.menuItem.view = TeamView(teamState: teamState)
                self.statusItem.image = NSImage(named: "icon-coloured")
            }
        }
    }
    
    func menuDidClose(menu: NSMenu) {
        dataManager.menuViewed()
        statusItem.image = NSImage(named: "icon-white")
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