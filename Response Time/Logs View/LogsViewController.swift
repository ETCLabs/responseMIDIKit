//
//  LogsViewController.swift
//  Response Time
//
//  Created by Sam Smallman on 26/07/2018.
//  Copyright © 2018 etc. All rights reserved.
//

import Cocoa

class LogsViewController: NSViewController {
    
    let formatter = DateFormatter()
    
    @IBOutlet var textView: NSTextView!
    @IBOutlet weak var box: NSBox!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        formatter.dateFormat = "HH:mm:ss.SSS"
        textView.textColor = ColoursStyleKit.blue
//        box.borderColor = ColoursStyleKit.blue
        let infoDictionary = Bundle.main.infoDictionary
        // Display the App Name and Version number in the Logs.
        guard let appName = infoDictionary?["CFBundleName"] as? String, let appVersion = infoDictionary?["CFBundleShortVersionString"] as? String else { return }
        textView.string += "[\(formatter.string(from: Date()))] \(appName) \(appVersion)\n"
        // Display the human readable copyright in the Logs.
        guard let copyright = infoDictionary?["NSHumanReadableCopyright"] as? String else { return }
        textView.string += "[\(formatter.string(from: Date()))] \(copyright)\n"
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.serverDidStartListening(_:)), name: Notification.Name.serverDidStartListening, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.serverDidStopListening(_:)), name: Notification.Name.serverDidStopListening, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.serverDidStartListening, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.serverDidStopListening, object: nil)
    }
    
    @objc func serverDidStartListening(_ notification: NSNotification) {
        log(string: "Server Started Listening")
    }
    
    @objc func serverDidStopListening(_ notification: NSNotification) {
        log(string: "Server Stopped Listening")
    }
    
    public func clearLogs() {
        textView.string = ""
    }
    
    public func log(string: String) {
        let time = formatter.string(from: Date())
        textView.string += "[\(time)] \(string)\n"
    }
    
}
