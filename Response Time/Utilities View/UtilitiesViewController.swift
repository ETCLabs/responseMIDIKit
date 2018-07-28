//
//  UtilitiesViewController.swift
//  Response Time
//
//  Created by Sam Smallman on 26/07/2018.
//  Copyright © 2018 etc. All rights reserved.
//

import Cocoa
import responseMIDIKit

class UtilitiesViewController: NSViewController {
    
    private let server: ResponseServer
    private var terminator: MIDIServer.Terminator = .none
    private var selectedInterface: Interface?
    
    @IBOutlet weak var interfacePopUpButton: NSPopUpButton!
    @IBOutlet weak var terminatorPopUpButton: NSPopUpButton!
    @IBOutlet weak var portTextField: NSTextField!
    @IBOutlet weak var joinMulticastGroupButton: NSButton!
    @IBOutlet weak var multicastGroupTextField: NSTextField!
    @IBOutlet weak var listeningButton: NSButton!
    
    init(server: ResponseServer) {
        self.server = server
        super.init(nibName: NSNib.Name(rawValue: "UtilitiesViewController"), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    override func viewDidLoad() {
        createInterfacePopUpItems()
        selectFirstInterface()
        NotificationCenter.default.addObserver(self, selector: #selector(self.serverDidStartListening(_:)), name: Notification.Name.serverDidStartListening, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.serverDidStopListening(_:)), name: Notification.Name.serverDidStopListening, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.popUpWillPopUp(_:)), name: NSPopUpButton.willPopUpNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.serverDidStartListening, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.serverDidStopListening, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSPopUpButton.willPopUpNotification, object: nil)
    }
    
    @objc func serverDidStartListening(_ notification: NSNotification) {
        enableProperties(isEnabled: false)
        listeningButton.title = "Stop Listening"
    }
    
    @objc func serverDidStopListening(_ notification: NSNotification) {
        enableProperties(isEnabled: true)
        listeningButton.title = "Start Listening"
    }
    
    @objc func popUpWillPopUp(_ notification: NSNotification) {
        guard let object = notification.object as? NSPopUpButton else { return }
        if object == interfacePopUpButton {
            createInterfacePopUpItems()
        }
    }
    
    private func createInterfacePopUpItems() {
        interfacePopUpButton.removeAllItems()
        for interface in Interface.allInterfaces() where !interface.isLoopback && interface.family == .ipv4 && interface.isRunning {
            let item = NSMenuItem(title: interface.displayText, action: nil, keyEquivalent: "")
            interfacePopUpButton.menu?.addItem(item)
            if selectedInterface?.displayName == interface.displayText {
                interfacePopUpButton.select(item)
            }
        }
    }
    
    private func selectFirstInterface() {
        for interface in Interface.allInterfaces() where !interface.isLoopback && interface.family == .ipv4 && interface.isRunning {
            selectedInterface = interface
            interfacePopUpButton.setTitle(interface.displayText)
            break
        }
    }
    
    private func enableProperties(isEnabled: Bool) {
        interfacePopUpButton.isEnabled = isEnabled
        terminatorPopUpButton.isEnabled = isEnabled
        portTextField.isEnabled = isEnabled
        joinMulticastGroupButton.isEnabled = isEnabled
        multicastGroupTextField.isEnabled = isEnabled
    }
    
    @IBAction func joinMulticastGroupButtonDidClick(_ sender: Any) {
        if joinMulticastGroupButton.state == .on {
            multicastGroupTextField.isHidden = false
        } else {
            multicastGroupTextField.isHidden = true
        }
    }
    
    private func startListening() {
        guard let interface = selectedInterface?.address else { return }
        
        if validatePort(number: portTextField.intValue) {
            if joinMulticastGroupButton.state == .on {
                if validateMulticastGroup(group: multicastGroupTextField.stringValue) {
                    // Start listening on a port joining the multicast group.
                    server.startListening(withInterface: interface, port: UInt16(portTextField.intValue), multicastGroup: multicastGroupTextField.stringValue, terminator: terminator)
                }
            } else {
                // Start listening on a port.
                server.startListening(withInterface: interface, port: UInt16(portTextField.intValue), terminator: terminator)
            }
        }
    }
    
    @IBAction func toggleListening(_ sender: Any) {
        if server.isListening {
            server.stopListening()
        } else {
            startListening()
        }
    }
    
    @IBAction func selectedInterfaceDidChange(_ sender: Any) {
        guard let selectedItem = interfacePopUpButton.selectedItem else { return }
        for interface in Interface.allInterfaces() where !interface.isLoopback && interface.family == .ipv4 && interface.isRunning {
            if interface.displayText == selectedItem.title {
                selectedInterface = interface
            }
        }
    }
    
    @IBAction func selectedTerminatorDidChange(_ sender: Any) {
        switch terminatorPopUpButton.indexOfSelectedItem {
        case 1:
            terminator = .carriageReturn
        case 2:
            terminator = .lineFeed
        case 3:
            terminator = .carriageReturnLineFeed
        default:
            terminator = .none
        }
    }
    
    private func validatePort(number: Int32) -> Bool {
        return number > 0 && 65535 >= number
    }
    
    private func validateMulticastGroup(group: String) -> Bool {
        return true
    }
}
