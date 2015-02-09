//
//  OptionsPanelController.swift
//  MenuSlack
//
//  Created by Steven Masuch on 2015-02-04.
//  Copyright (c) 2015 Zanopan. All rights reserved.
//

import Cocoa

class OptionsPanelController: NSWindowController {
    
    @IBOutlet weak var tokenTextField : NSTextField?
    weak var menuController: MenuController?
    var existingToken: String?

    override func windowDidLoad() {
        super.windowDidLoad()
        window?.level = kCGStatusWindowLevelKey
        if let existingToken = existingToken {
            tokenTextField?.stringValue = existingToken
        }
    }
    
    @IBAction func saveToken(sender: AnyObject) {
        if let newToken = tokenTextField?.stringValue {
            menuController?.changeToken(newToken)
            self.close()
        }
    }
    
    @IBAction func cancel (sender: AnyObject) {
        self.dismissController(sender)
    }
    
}
