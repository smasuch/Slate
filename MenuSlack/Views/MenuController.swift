//
//  MenuController.swift
//  MenuSlack
//
//  Created by Steven Masuch on 2015-01-29.
//  Copyright (c) 2015 Zanopan. All rights reserved.
//

import Cocoa

class MenuController: NSObject, NSMenuDelegate, TeamStateHandler, ConnectionManagerDelegate {
    let menu: NSMenu
    let menuItem: NSMenuItem
    var statusItem: NSStatusItem
    var connectionManager: ConnectionManager
    var dataManager: DataManager
    var optionsController: OptionsPanelController?
    var aboutController: AboutPanelController?
    @IBOutlet var authView: NSView?
    
    override init() {
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-2.0)
        connectionManager = ConnectionManager()
        dataManager = DataManager()
        
        menu = NSMenu()
        menu.autoenablesItems = false
        menu.minimumWidth = 300.0
        menuItem = NSMenuItem(title: "Loading", action: "", keyEquivalent:"")
        
        super.init()
        
        connectionManager.resultHandler = dataManager
        connectionManager.connectionDelegate = self
        dataManager.requestHandler = connectionManager
        dataManager.teamStateHandler = self
        
        statusItem.menu = menu
        menu.delegate = self
        statusItem.image = NSImage(named: "icon-Template")
        menu.addItem(menuItem)

        menu.addItem(NSMenuItem.separatorItem())
                
        if let savedToken = NSUserDefaults.standardUserDefaults().valueForKey("AuthToken") as! String? {
            connectionManager.initiateConnection(savedToken)
            
            let optionsMenuItem = NSMenuItem(title: "Team Selection...", action: "showOptionsPanel", keyEquivalent:"")
            optionsMenuItem.target = self
            menu.addItem(optionsMenuItem)
            
        } else {
            // Display the view to prompt for the auth token
            
            NSBundle.mainBundle().loadNibNamed("MenuAuthenticationPrompt", owner: self, topLevelObjects: nil)
            menuItem.view = authView
        }
        
        let aboutMenuItem = NSMenuItem(title: "About", action: "showAboutPanel", keyEquivalent:"")
        aboutMenuItem.target = self
        menu.addItem(aboutMenuItem)
        
        let quitMenuItem = NSMenuItem(title: "Quit", action: "terminate:", keyEquivalent: "")
        quitMenuItem.target = NSApplication.sharedApplication()
        menu.addItem(quitMenuItem)
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
    
    func connectionStatusChanged(manager: ConnectionManager, status: ConnectionStatus) {
        switch status {
        case .Authenticating:
            menuItem.title = "Authenticating..."
        case .AuthenticationFailed(let failureString):
            menuItem.title = "Authentication failed, reason: " + failureString
        case .AuthenticationSucceeded:
            menuItem.title = "Authenticated, connecting to websocket..."
        case .SocketConnected:
            menuItem.title = "Connected to socket, loading messages..."
        case .SocketFailed:
            menuItem.title = "Socket failed, trying to reconnect..."
        case .ServerNotResponding:
            menuItem.title = "Server not responding, waiting for response..."
        }
    }
    
    func menuDidClose(menu: NSMenu) {
        dataManager.teamViewed()
        self.statusItem.image = NSImage(named: "icon-Template")
    }
    
    @IBAction func showOptionsPanel(sender: AnyObject) {
        showOptionsPanel()
    }
    
    func showOptionsPanel() {
        optionsController = OptionsPanelController(windowNibName: "OptionsPanelController")
        if let savedToken = NSUserDefaults.standardUserDefaults().valueForKey("AuthToken") as! String? {
            optionsController?.existingToken = savedToken
        }
        optionsController?.menuController = self
        NSApp.activateIgnoringOtherApps(true)
        optionsController?.showWindow(nil)
    }
    
    func showAboutPanel() {
        aboutController = AboutPanelController(windowNibName: "AboutPanelController")
        aboutController?.showWindow(nil)
    }
    
    func changeToken(token: String) {
        menuItem.view = nil;
        NSUserDefaults.standardUserDefaults().setValue(token, forKey: "AuthToken")
        dataManager.clearData()
        connectionManager.initiateConnection(token)
    }
}