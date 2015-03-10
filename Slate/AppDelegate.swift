//
//  AppDelegate.swift
//  Slate
//
//  Created by Steven Masuch on 2015-01-11.
//  Copyright (c) 2015 Zanopan. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    
    var menuController: MenuController?

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        menuController = MenuController()
    }
}

