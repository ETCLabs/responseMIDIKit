//
//  TimecodeViewController.swift
//  Response Time
//
//  Created by Sam Smallman on 26/07/2018.
//  Copyright © 2018 etc. All rights reserved.
//

import Cocoa

class TimecodeViewController: NSViewController {

    @IBOutlet weak var timecodeTextField: NSTextField!
    @IBOutlet weak var fpsTextField: NSTextField!
    
    public func updateTimecode(with timecode: String) {
        timecodeTextField.stringValue = timecode
    }
    
    public func updateFrameRate(with frameRate: String) {
        fpsTextField.stringValue = frameRate
    }
    
    public func clearTimecode() {
        timecodeTextField.stringValue = ""
        fpsTextField.stringValue = ""
    }
    
}
