//
//  MenuController.swift
//  MenuSlack
//
//  Created by Steven Masuch on 2015-01-29.
//  Copyright (c) 2015 Zanopan. All rights reserved.
//

import Cocoa

class MenuController: NSObject, NSMenuDelegate, TeamStateHandler {
    let menu: NSMenu
    let menuItem: NSMenuItem
    var statusItem: NSStatusItem
    var connectionManager: ConnectionManager
    var dataManager: DataManager
    var optionsController: OptionsPanelController?
    
    override init() {
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-2.0)
        connectionManager = ConnectionManager()
        dataManager = DataManager()
        
        menu = NSMenu()
        menu.minimumWidth = 300.0
        menuItem = NSMenuItem()
        
        super.init()
        
        connectionManager.resultHandler = dataManager
        dataManager.requestHandler = connectionManager
        dataManager.teamStateHandler = self
        
        statusItem.menu = menu
        menu.delegate = self
        statusItem.image = NSImage(named: "icon-white")
        menu.addItem(menuItem)
        
        menu.addItem(NSMenuItem.separatorItem())
        
        let optionsMenuItem = NSMenuItem(title: "Options", action: "showOptionsPanel", keyEquivalent:"")
        optionsMenuItem.target = self
        menu.addItem(optionsMenuItem)
        
        let quitMenuItem = NSMenuItem(title: "Quit", action: "terminate:", keyEquivalent: "")
        quitMenuItem.target = NSApplication.sharedApplication()
        menu.addItem(quitMenuItem)
        
        if let savedToken = NSUserDefaults.standardUserDefaults().valueForKey("AuthToken") as String? {
            connectionManager.initiateConnection(savedToken)
        }
        
        
    }
    
    func handleTeamState(state: TeamState) {
        dispatch_async(dispatch_get_main_queue()) {
            self.menuItem.view = TeamView(teamState: state)
            if state.hasUnreadMessages {
                self.statusItem.image = NSImage(named: "icon-coloured")
            } else {
                self.statusItem.image = NSImage(named: "icon-white")
            }
        }
    }
    
    func menuDidClose(menu: NSMenu) {
        dataManager.teamViewed()
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