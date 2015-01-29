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
    
    override init() {
        self.statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1.0)
        connectionManager = ConnectionManager()
        let eventQueue = Queue<Event>()
        connectionManager.eventQueue = eventQueue
        dataManager = DataManager()
        dataManager.eventQueue = eventQueue
    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        self.statusItem.title = "Slack"
        println(statusItem)
        let menu = NSMenu()
        menu.addItemWithTitle("Quit", action: "terminate", keyEquivalent: "")
        self.statusItem.menu = menu
        
        connectionManager.initiateConnection()
    }

    func applicationWillTerminate(aNotification: NSNotification) {

    }


}

