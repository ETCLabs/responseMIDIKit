//
//  BackgroundView.swift
//  Response Time
//
//  Created by Sam Smallman on 25/07/2018.
//  Copyright © 2018 etc. All rights reserved.
//

import Cocoa

class BackgroundView: NSView {
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        NSColor(calibratedRed: 0.094, green: 0.094, blue: 0.094, alpha: 1).setFill()
        dirtyRect.fill()
    }
    
}
