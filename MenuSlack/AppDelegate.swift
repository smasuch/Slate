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
    
    var socketReceiver: SocketReceiver?
    
    override init() {
        self.statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1.0)
    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        self.statusItem.title = "Slack"
        println(statusItem)
        let menu = NSMenu()
        menu.addItemWithTitle("Quit", action: "terminate", keyEquivalent: "")
        self.statusItem.menu = menu
        
        self.socketReceiver = SocketReceiver()
        socketReceiver?.initiateConnection()
    }

    func applicationWillTerminate(aNotification: NSNotification) {

    }


}

