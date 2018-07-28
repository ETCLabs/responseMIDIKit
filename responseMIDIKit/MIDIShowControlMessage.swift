//
//  MIDIShowControlMessage.swift
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

public class MIDIShowControlMessage: MIDIPacket {
    
    public let deviceID: Int
    public let commandFormat: String
    public let command: String
    public var list: Double?
    public var cue:  Double?
    public var path: Double?
    
    public init(hexDeviceID: String, hexCommandFormat: String, hexCommand: String, cue: Double, list: Double, path: Double) {
        if let deviceIDInt = Int(hexDeviceID, radix: 16) {
           self.deviceID = deviceIDInt
        } else {
           self.deviceID = -1
        }
        var formatString = "Unknown"
        if let intCommandFormat = Int(hexCommandFormat), intCommandFormat < 10 {
            let newCommandFormat = "0\(intCommandFormat)"
            for format in MIDIDictionary.MIDIShowControlComandFormats.allValues where format.hex() == newCommandFormat {
                formatString = format.commandFormat()
            }
        } else {
            let uppercaseString = hexCommandFormat.uppercased()
            for format in MIDIDictionary.MIDIShowControlComandFormats.allValues where format.hex() == uppercaseString {
                formatString = format.commandFormat()
            }
        }
        self.commandFormat = formatString
        var commandString = "Unknown"
        if let intCommand = Int(hexCommand), intCommand < 10 {
            let newCommand = "0\(intCommand)"
            for command in MIDIDictionary.MIDIShowControlComands.allValues where command.hex() == newCommand {
                commandString = command.command()
            }
        } else {
            let uppercaseString = hexCommand.uppercased()
            for command in MIDIDictionary.MIDIShowControlComands.allValues where command.hex() == uppercaseString {
                commandString = command.command()
            }
        }
        self.command = commandString
        if list > 0 {
           self.list = list
        }
        if cue > 0 {
            self.cue = cue
        }
        if path > 0 {
            self.path = path
        }
    }
    
    public func message() -> String {
        var string = "Device ID: \(deviceID), Command Format: \(commandFormat), Command: \(command)"
        if let cueNumber = cue {
            string.append(" - Cue: \(cueNumber)")
        }
        if let cueList = list {
            string.append(" List: \(cueList)")
        }
        if let cuePath = path {
            string.append(" Path: \(cuePath)")
        }
        return string
    }

}
