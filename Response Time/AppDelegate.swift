//
//  AppDelegate.swift
//  Response Time
//
//  Created by Sam Smallman on 24/07/2018.
//  Copyright © 2018 etc. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        guard let window = NSApplication.shared.mainWindow else { return }
        window.appearance = NSAppearance(named: .vibrantDark)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

