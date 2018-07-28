//
//  ResponseServer.swift
//  Response Time
//
//  Created by Sam Smallman on 26/07/2018.
//  Copyright © 2018 etc. All rights reserved.
//

import Foundation
import responseMIDIKit

class ResponseServer: MIDIPacketDestination {
    
    private let server = MIDIServer()
    private let logs: LogsViewController
    private let timecode: TimecodeViewController
    private var multicastGroup: String?
    public var isListening = false
    
    init(logs: LogsViewController, timecode: TimecodeViewController) {
        self.logs = logs
        self.timecode = timecode
        server.delegate = self
    }
    
    public func startListening(withInterface interface: String, port: UInt16, terminator: MIDIServer.Terminator) {
        server.interface = interface
        server.port = port
        server.terminator = terminator
        do {
            try server.startListening()
            NotificationCenter.default.post(name: Notification.Name.serverDidStartListening, object: self, userInfo: nil)
            isListening = true
        } catch let error as NSError {
            logs.log(string: error.localizedDescription)
        }
    }
    
    public func startListening(withInterface interface: String, port: UInt16, multicastGroup: String, terminator: MIDIServer.Terminator) {
        self.server.interface = interface
        self.server.port = port
        self.server.terminator = terminator
        self.multicastGroup = multicastGroup
        do {
            try server.startListening(with: [multicastGroup])
            logs.log(string: "Server Joined Multicast Group: \(multicastGroup)")
            NotificationCenter.default.post(name: Notification.Name.serverDidStartListening, object: self, userInfo: nil)
            isListening = true
        } catch let error as NSError {
            logs.log(string: error.localizedDescription)
        }
    }
    
    public func stopListening() {
        leaveMulticastGroup()
        server.stopListening()
        NotificationCenter.default.post(name: Notification.Name.serverDidStopListening, object: self, userInfo: nil)
        isListening = false
    }
    
    private func leaveMulticastGroup() {
        guard let group = multicastGroup else { return }
        do {
            try server.leaveMulticast(group: group)
            logs.log(string: "Server Left Multicast Group: \(group)")
        } catch let error as NSError {
            logs.log(string: error.localizedDescription)
        }
        multicastGroup = nil
    }
    
    // MARK: - MIDI Packet Destination Delegate
    
    func take(timecodeMessage: MIDITimecodeMessage) {
        timecode.updateTimecode(with: timecodeMessage.timecode())
        timecode.updateFrameRate(with: timecodeMessage.framerate())
    }
    
    func take(showControlMessage: MIDIShowControlMessage) {
        logs.log(string: showControlMessage.message())
    }
    
    func take(voiceMessage: MIDIVoiceMessage) {
        logs.log(string: voiceMessage.message())
    }
}


