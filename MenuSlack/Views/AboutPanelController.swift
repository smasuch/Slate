//
//  AboutPanelController.swift
//  MenuSlack
//
//  Created by Steven Masuch on 2015-02-23.
//  Copyright (c) 2015 Zanopan. All rights reserved.
//

import Cocoa

class AboutPanelController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        window?.level = kCGStatusWindowLevelKey
    }
    
}
