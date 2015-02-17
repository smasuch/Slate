//
//  MSImageView.swift
//  MenuSlack
//
//  Created by Steven Masuch on 2015-02-14.
//  Copyright (c) 2015 Zanopan. All rights reserved.
//

import Cocoa

class MSImageView: NSImageView {

    var imageURL: NSURL?
    
    override func mouseUp(theEvent: NSEvent) {
        super.mouseUp(theEvent)
        if let imageURL = imageURL {
            NSWorkspace.sharedWorkspace().openURL(imageURL)
        }
    }
}