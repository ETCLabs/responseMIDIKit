//
//  MIDIServer.swift
//  responseMIDIKit
//
//  Created by Sam Smallman on 08/03/2018.
//  Copyright © 2017 Sam Smallman. http://sammy.io
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

// MARK: Server

import Foundation
import Cocoa
import CocoaAsyncSocket

public class MIDIServer: NSObject, GCDAsyncSocketDelegate, GCDAsyncUdpSocketDelegate {
    
    public enum Terminator: String {
        case none = ""                       // No terminator
        case carriageReturn = "\r"            // Carriage Return
        case lineFeed = "\n"                  // Line Feed
        case carriageReturnLineFeed = "\r\n"    // Carriage Return + Line Feed
    }
    
    private(set) var udpSocket: Socket!
    private var joinedMulticastGroups: [String] = []
    public var interface: String = "localhost" {
        willSet {
            self.udpSocket?.interface = newValue
        }
    }
    public var port: UInt16 = 0 {
        willSet {
            self.udpSocket?.port = newValue
        }
    }
    
    public var terminator: Terminator = .none
    private var udpReplyPort: UInt16 = 0
    public var delegate: MIDIPacketDestination?
    
    public var h: UInt8 = 0
    public var m: UInt8 = 0
    public var s: UInt8 = 0
    public var f: UInt8 = 0
    public var tcMode: Int8 = 0
    public var validMask: UInt8 = 0
    
    private var lastQuarterFrameReceived: UInt8?
    private var timeLastQuarterFrameReceived: TimeInterval = 0
    private var timeLastFrameReceived: TimeInterval = 0
    private var quarterFrameTimer: Timer?
    
    public override init() {
        super.init()
        let rawUDPSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
        self.udpSocket = Socket(with: rawUDPSocket)
    }
    
    deinit {
        for group in joinedMulticastGroups {
            try! udpSocket.leaveMulticast(group: group)
        }
    }
    
    // MARK: Multicasting
    
    public func leaveMulticast(group: String) throws {
        try udpSocket.leaveMulticast(group: group)
        if joinedMulticastGroups.contains(group) {
            if let index = joinedMulticastGroups.index(of: group) {
                joinedMulticastGroups.remove(at: index)
            }
        }
    }
    
    // MARK: Listening
    
    public func startListening() throws {
        try udpSocket.startListening()
    }
    
    public func startListening(with groups: [String]) throws {
        joinedMulticastGroups = groups
        try udpSocket.startListening(with: groups)
    }
    
    public func stopListening() {
        for group in joinedMulticastGroups {
            do {
                try udpSocket.leaveMulticast(group: group)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        udpSocket.stopListening()
    }
    
    // MARK: GCDAsyncSocketDelegate
    
    public func newSocketQueueForConnection(fromAddress address: Data, on sock: GCDAsyncSocket) -> DispatchQueue? {
        return nil
    }

    
    public func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        #if Server_Debug
        debugPrint("Socket: \(sock) didDisconnect, withError: \(String(describing: err))")
        #endif
    }
    
    // MARK: GCDAsyncUDPSocketDelegate
    
    public func udpSocket(_ sock: GCDAsyncUdpSocket, didConnectToAddress address: Data) {
        #if Server_Debug
        debugPrint("UDP Socket: \(sock) didConnectToAddress \(address)")
        #endif
    }
    
    public func udpSocket(_ sock: GCDAsyncUdpSocket, didNotConnect error: Error?) {
        #if Server_Debug
        debugPrint("UDP Socket: \(sock) didNotConnect, dueToError: \(String(describing: error?.localizedDescription))")
        #endif
    }
    
    public func udpSocket(_ sock: GCDAsyncUdpSocket, didSendDataWithTag tag: Int) {
        #if Server_Debug
        debugPrint("UDP Socket: \(sock) didSendDataWithTag: \(tag)")
        #endif
    }
    
    public func udpSocket(_ sock: GCDAsyncUdpSocket, didNotSendDataWithTag tag: Int, dueToError error: Error?) {
        #if Server_Debug
        debugPrint("UDP Socket: \(sock) didNotSendDataWithTag: \(tag), dueToError: \(String(describing: error?.localizedDescription))")
        #endif
    }
    
    public func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {        
        let rawReplySocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
        let socket = Socket(with: rawReplySocket)
        socket.host = GCDAsyncUdpSocket.host(fromAddress: address)
        socket.port = self.udpReplyPort
        guard let packetDestination = delegate else { return }
        do {
            try  MIDIParser().process(MIDIDate: data, from: self, for: packetDestination, with: socket, and: terminator)
        } catch MIDIParserError.unrecognisedData {
            debugPrint("Error: Unrecognized data \(data)")
        } catch {
            debugPrint("Other Error: \(error)")
        }
    }
    
    public func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError error: Error?) {
        #if Server_Debug
        debugPrint("UDP Socket: \(sock) Did Close. With Error: \(String(describing: error?.localizedDescription))")
        #endif
    }
    
    public func newFrameReceived() {
        // if tcMode is invalid OR validMask != 1111 1111
        if tcMode == MIDIDictionary.MTCFrameRate.invalid.rawValue || validMask != 0xFF {
            return
        }
        guard let packetDestination = delegate else { return }
        packetDestination.take(timecodeMessage: MIDITimecodeMessage(hour: self.h, minute: self.m, second: self.s, frame: self.f, frameRate: self.tcMode))
        timeLastFrameReceived = Date.timeIntervalSinceReferenceDate
        quarterFrameTimer?.invalidate()
        quarterFrameTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.endQuarterFrameTimer), userInfo: nil, repeats: false)
    }
    
    @objc func endQuarterFrameTimer() {
        if Date.timeIntervalSinceReferenceDate - timeLastFrameReceived > 0.1 {
            guard let packetDestination = delegate else { return }
            packetDestination.take(timecodeMessage: MIDITimecodeMessage(hour: self.h, minute: self.m, second: self.s, frame: self.f, frameRate: self.tcMode))
            tcMode = -1
            validMask = 0
        }
        quarterFrameTimer = nil
    }
    
    
}

