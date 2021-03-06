//
//  MenuController.swift
//  Slate
//
//  Created by Steven Masuch on 2015-01-29.
//  Copyright (c) 2015 Zanopan. All rights reserved.
//

//  The MenuController is the central controller for the app.
//  It sets up the connection & data managers and manages the menu item that displays the team view.


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
        
        addMenuItems()
    }
    
    
    /** 
        Sets up the items in the menu based on if there's a saved token.
    */
    func addMenuItems() {
        
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
    
    /**
        Record that the messages were viewed.
    */
    func menuDidClose(menu: NSMenu) {
        dataManager.teamViewed()
        self.statusItem.image = NSImage(named: "icon-Template")
    }
    
    /**
        Show the options dialogue from a button click.
    */
    @IBAction func showOptionsPanel(sender: AnyObject) {
        showOptionsPanel()
    }
    
    /**
        Show the options dialogue, where users can change the team token.
    */
    func showOptionsPanel() {
        optionsController = OptionsPanelController(windowNibName: "OptionsPanelController")
        if let savedToken = NSUserDefaults.standardUserDefaults().valueForKey("AuthToken") as! String? {
            optionsController?.existingToken = savedToken
        }
        optionsController?.menuController = self
        NSApp.activateIgnoringOtherApps(true)
        optionsController?.showWindow(nil)
    }
    
    /**
        Show the about panel.
    */
    func showAboutPanel() {
        aboutController = AboutPanelController(windowNibName: "AboutPanelController")
        aboutController?.showWindow(nil)
    }
    
    
    /**
        Change the authentication token to a new value and initiate a new connection based on that.
    
        :param: token New token to use for team authentication.
    */
    func changeToken(token: String) {
        menuItem.view = nil;
        NSUserDefaults.standardUserDefaults().setValue(token, forKey: "AuthToken")
        menu.removeAllItems()
        addMenuItems()
        dataManager.clearData()
        connectionManager.initiateConnection(token)
    }
    
    // MARK: TeamStateHandler methods
    
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
    
    // MARK: ConnectionManagerDelegate methods
    
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
}