//
//  MSImageView.swift
//  Slate
//
//  Created by Steven Masuch on 2015-02-14.
//  Copyright (c) 2015 Zanopan. All rights reserved.

//  An imageview subclass that acts as a linked button, basically.

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
