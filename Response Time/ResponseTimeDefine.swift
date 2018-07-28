//
//  ResponseTimeDefine.swift
//  Response Time
//
//  Created by Sam Smallman on 26/07/2018.
//  Copyright © 2018 etc. All rights reserved.
//

import Cocoa

extension Notification.Name {
    
    static let serverDidStartListening = Notification.Name("serverDidStartListening")
    static let serverDidStopListening = Notification.Name("serverDidStopListening")
    
}

public class ColoursStyleKit : NSObject {
    
    //// Cache
    private struct Cache {
        static let blue: NSColor = NSColor(calibratedRed: 0.11, green: 0.52, blue: 0.98, alpha: 1)
    }
    
    //// Colours
    public class var blue: NSColor { return Cache.blue }
    
}


