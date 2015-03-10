//
//  AboutPanelController.swift
//  Slate
//
//  Created by Steven Masuch on 2015-02-23.
//  Copyright (c) 2015 Zanopan. All rights reserved.

//  Just a little class for the About dialogue.

import Cocoa

class AboutPanelController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        window?.level = kCGStatusWindowLevelKey
    }
    
}
