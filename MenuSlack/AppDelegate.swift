//
//  AppDelegate.swift
//  MenuSlack
//
//  Created by Steven Masuch on 2015-01-11.
//  Copyright (c) 2015 Zanopan. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    
    var statusItem: NSStatusItem
    
    var connectionManager: ConnectionManager
    
    var dataManager: DataManager
    
    var menuController: MenuController?
    
    override init() {
        self.statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1.0)
        connectionManager = ConnectionManager()
        dataManager = DataManager()
    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        let menu = NSMenu()
        menu.addItemWithTitle("Quit", action: "terminate", keyEquivalent: "")
        self.statusItem.menu = menu
        
        
        let eventQueue = Queue<Event>()
        connectionManager.eventQueue = eventQueue
        
        dataManager.eventQueue = eventQueue
        menuController = MenuController(menu: menu)
        let stateQueue = Queue<TeamState>()
        dataManager.stateQueue = stateQueue
        menuController?.stateQueue = stateQueue
        
        self.statusItem.title = "Slack"
        
        connectionManager.initiateConnection()
    }

    func applicationWillTerminate(aNotification: NSNotification) {

    }


}

