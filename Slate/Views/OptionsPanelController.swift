//
//  OptionsPanelController.swift
//  Slate
//
//  Created by Steven Masuch on 2015-02-04.
//  Copyright (c) 2015 Zanopan. All rights reserved.
//

import Cocoa

class OptionsPanelController: NSWindowController {
    
    @IBOutlet weak var tokenTextField : NSTextField?
    weak var menuController: MenuController?
    // TODO: create a delegate for this, rather than a direct reference
    var existingToken: String?

    override func windowDidLoad() {
        super.windowDidLoad()
        window?.initialFirstResponder = tokenTextField
        window?.level = kCGStatusWindowLevelKey
        if let existingToken = existingToken {
            tokenTextField?.stringValue = existingToken
        }
    }
    
    /**
        Tell the menu controller to save the current token value and close the options dialogue.
    
        :param: sender The object that sent this message.
    */
    @IBAction func saveToken(sender: AnyObject) {
        if let newToken = tokenTextField?.stringValue {
            menuController?.changeToken(newToken)
            self.close()
        }
    }
    
    
    /**
        Open the Slack API website to the page where the user can request a token.
    
        :param: sender The object that sent this message.
    */
    @IBAction func openSlackApiWebsite(sender: AnyObject) {
        if let websiteURL = NSURL(string: "https://api.slack.com/web") {
            NSWorkspace.sharedWorkspace().openURL(websiteURL)
        }
    }

    /**
        Close this dialogue, making no changes to the saved token value.
    
        :param: sender The object that sent this message.
    */
    @IBAction func cancel (sender: AnyObject) {
        close()
    }
}