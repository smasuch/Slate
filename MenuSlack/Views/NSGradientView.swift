//
//  NSGradientView.swift
//  MenuSlack
//
//  Created by Steven Masuch on 2015-02-09.
//  Copyright (c) 2015 Zanopan. All rights reserved.
//

//  Just a little view to provide a vertical gradient effect.

import Cocoa

class NSGradientView: NSView {
    var topColor: NSColor?
    var bottomColor: NSColor?

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        
        var actualTopColor = topColor
        var actualBottomColor = bottomColor
        if actualTopColor == nil {
            if actualBottomColor != nil {
                actualTopColor = actualBottomColor
            } else {
                actualTopColor = NSColor.blackColor()
            }
        }
        
        if actualBottomColor == nil {
            actualBottomColor = actualTopColor
        }
        
        let gradient = NSGradient(startingColor: actualTopColor!, endingColor: actualBottomColor!)
        gradient.drawInRect(self.bounds, angle: -90.0)
    }
}
