//
//  MIDISocket.swift
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

// MARK: Socket

import Foundation
import CocoaAsyncSocket

extension Socket: CustomStringConvertible {
    public var description: String {
        return "UDP Socket \(self.host ?? "No Host"):\(self.port)"
    }
}

public class Socket {
    
    private let timeout: TimeInterval = 3.0
    
    public private(set) var udpSocket: GCDAsyncUdpSocket?
    public var interface: String?
    public var host: String?
    public var port: UInt16 = 0
    
    public var isConnected: Bool {
        get {
            guard let socket = self.udpSocket else { return false }
            return socket.isConnected()
        }
    }
    
    init(with udpSocket: GCDAsyncUdpSocket) {
        self.udpSocket = udpSocket
        self.interface = nil
        self.host = "localhost"
    }
    
    deinit {
        self.udpSocket?.setDelegate(nil)
        self.udpSocket = nil
    }
    
    func joinMulticast(group: String) throws {
        guard let socket = udpSocket else { return }
        if let aInterface = self.interface {
            try socket.joinMulticastGroup(group, onInterface: aInterface)
            #if Socket_Debug
            debugPrint("UDP Socket - Joined Multicast Group: \(group) on interface: \(aInterface)")
            #endif
        } else {
            try socket.joinMulticastGroup(group)
            #if Socket_Debug
            debugPrint("UDP Socket - Joined Multicast Group: \(group)")
            #endif
        }
    }
    
    func leaveMulticast(group: String) throws {
        guard let socket = udpSocket else { return }
        if let aInterface = self.interface {
            try socket.leaveMulticastGroup(group, onInterface: aInterface)
        } else {
            try socket.leaveMulticastGroup(group)
        }
        #if Socket_Debug
        debugPrint("UDP Socket - Left Multicast Group: \(group)")
        #endif
    }
    
    func startListening() throws {
        if let socket = self.udpSocket {
            do {
                try socket.enableReusePort(true)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            if let aInterface = self.interface {
                #if Socket_Debug
                debugPrint("UDP Socket - Start Listening on Interface: \(aInterface), withPort: \(port)")
                #endif
                try socket.bind(toPort: port, interface: aInterface)
                try socket.beginReceiving()
            } else {
                #if Socket_Debug
                debugPrint("UDP Socket - Start Listening on Port: \(port)")
                #endif
                try socket.bind(toPort: port)
                try socket.beginReceiving()
            }
        }
    }
    
    func startListening(with groups: [String]) throws {
        if let socket = self.udpSocket {
            try socket.enableReusePort(true)
            #if Socket_Debug
            debugPrint("UDP Socket - Start Listening on Port: \(port)")
            #endif
            try socket.bind(toPort: port)
            try socket.beginReceiving()
            for group in groups {
                try joinMulticast(group: group)
            }
        }
    }
    
    func stopListening() {
        guard let socket = self.udpSocket else { return }
        socket.close()
        #if Socket_Debug
        debugPrint("UDP Socket - Stop Listening")
        #endif
    }
    
}
