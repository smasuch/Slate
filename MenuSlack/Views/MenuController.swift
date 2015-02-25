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
    var aboutController: AboutPanelController?
    
    override init() {
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-2.0)
        connectionManager = ConnectionManager()
        dataManager = DataManager()
        
        menu = NSMenu()
        menu.minimumWidth = 300.0
        menuItem = NSMenuItem(title: "Loading", action: "", keyEquivalent:"")
        
        super.init()
        
        connectionManager.resultHandler = dataManager
        dataManager.requestHandler = connectionManager
        dataManager.teamStateHandler = self
        
        statusItem.menu = menu
        menu.delegate = self
        statusItem.image = NSImage(named: "icon-Template")
        menu.addItem(menuItem)
        
        menu.addItem(NSMenuItem.separatorItem())
        
        let optionsMenuItem = NSMenuItem(title: "Options", action: "showOptionsPanel", keyEquivalent:"")
        optionsMenuItem.target = self
        menu.addItem(optionsMenuItem)
        
        let aboutMenuItem = NSMenuItem(title: "About", action: "showAboutPanel", keyEquivalent:"")
        aboutMenuItem.target = self
        menu.addItem(aboutMenuItem)
        
        let quitMenuItem = NSMenuItem(title: "Quit", action: "terminate:", keyEquivalent: "")
        quitMenuItem.target = NSApplication.sharedApplication()
        menu.addItem(quitMenuItem)
        
        if let savedToken = NSUserDefaults.standardUserDefaults().valueForKey("AuthToken") as! String? {
            connectionManager.initiateConnection(savedToken)
        }
    }
    
    func handleTeamState(state: TeamState) {
        dispatch_async(dispatch_get_main_queue()) {
            self.menuItem.view = TeamView(teamState: state)
            if state.hasUnreadMessages {
                self.statusItem.image = NSImage(named: "icon-Filled-Template")
            } else {
                self.statusItem.image = NSImage(named: "icon-Template")
            }
        }
    }
    
    func menuDidClose(menu: NSMenu) {
        dataManager.teamViewed()
        self.statusItem.image = NSImage(named: "icon-Template")
    }
    
    func showOptionsPanel() {
        optionsController = OptionsPanelController(windowNibName: "OptionsPanelController")
        if let savedToken = NSUserDefaults.standardUserDefaults().valueForKey("AuthToken") as! String? {
            optionsController?.existingToken = savedToken
        }
        optionsController?.menuController = self
        optionsController?.showWindow(nil)
    }
    
    func showAboutPanel() {
        aboutController = AboutPanelController(windowNibName: "AboutPanelController")
        aboutController?.showWindow(nil)
    }
    
    func changeToken(token: String) {
        menuItem.view = nil;
        NSUserDefaults.standardUserDefaults().setValue(token, forKey: "AuthToken")
        connectionManager.initiateConnection(token)
    }
}