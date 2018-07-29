//
//  WindowController.swift
//  Response Time
//
//  Created by Sam Smallman on 29/07/2018.
//  Copyright © 2018 ETC. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        guard let window = self.window else { return }
        window.appearance = NSAppearance(named: .vibrantDark)
    }

}
