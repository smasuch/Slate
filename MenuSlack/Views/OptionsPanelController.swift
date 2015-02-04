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

    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    @IBAction func saveToken(sender: AnyObject) {
        
    }
    
}
