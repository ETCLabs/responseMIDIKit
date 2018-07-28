//
//  MIDIVoiceMessage.swift
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

public class MIDIVoiceMessage: MIDIPacket {
    
    private let type: MIDIDictionary.MIDIVoiceMessageType
    private let channel: Int
    private let firstProperty: (property: MIDIDictionary.MIDIVoiceMessageProperty, value: Int)
    private let secondProperty: (property: MIDIDictionary.MIDIVoiceMessageProperty, value: Int)
    
    private init(type: MIDIDictionary.MIDIVoiceMessageType, channel: String, firstProperty: (property: MIDIDictionary.MIDIVoiceMessageProperty, value: String), secondProperty: (property: MIDIDictionary.MIDIVoiceMessageProperty, value: String)) {
        self.type = type
        if let channelInt = Int(channel, radix: 16) {
            self.channel = channelInt + 1
        } else {
            self.channel = -1
        }
        if type != .pitchBendChange {
            if let propertyInt = Int(firstProperty.value, radix: 16) {
                self.firstProperty = (firstProperty.property, propertyInt)
            } else {
                self.firstProperty = (firstProperty.property, -1)
            }
            if let propertyInt = Int(secondProperty.value, radix: 16) {
                self.secondProperty = (secondProperty.property, propertyInt)
            } else {
                self.secondProperty = (secondProperty.property, -1)
            }
        } else {
            if let propertyInt = Int(firstProperty.value) {
                self.firstProperty = (firstProperty.property, propertyInt)
            } else {
                self.firstProperty = (firstProperty.property, -1)
            }
            self.secondProperty = (secondProperty.property, -1)
        }
    }
    
    convenience init(noteOnWithChannel channel: String, noteNumber: String, andVelocity velocity: String) {
        self.init(type: .noteOn, channel: channel, firstProperty: (.noteNumber, noteNumber), secondProperty: (.velocity, velocity))
    }
    
    convenience init(noteOffWithChannel channel: String, noteNumber: String, andVelocity velocity: String) {
        self.init(type: .noteOff, channel: channel, firstProperty: (.noteNumber, noteNumber), secondProperty: (.velocity, velocity))
    }
    
    convenience init(programChangeWithChannel channel: String, andProgramNumber programNumber: String) {
        self.init(type: .programChange, channel: channel, firstProperty: (.programNumber, programNumber), secondProperty: (.invalid, "0"))
    }
    
    convenience init(controlChangeWithChannel channel: String, controlNumber: String, andControlValue controlValue: String) {
        self.init(type: .controlChange, channel: channel, firstProperty: (.controlNumber, controlNumber), secondProperty: (.controlValue, controlValue))
    }
    
    convenience init(keyPressureWithChannel channel: String, noteNumber: String, andPressureValue pressureValue: String) {
        self.init(type: .keyPressure, channel: channel, firstProperty: (.noteNumber, noteNumber), secondProperty: (.pressureValue, pressureValue))
    }
    
    convenience init(channelPressureWithChannel channel: String, andPressureValue pressureValue: String) {
        self.init(type: .channelPressure, channel: channel, firstProperty: (.pressureValue, pressureValue), secondProperty: (.invalid, "0"))
    }
    
    convenience init(pitchBendChangeWithChannel channel: String, andVelocity velocity: String) {
        self.init(type: .pitchBendChange, channel: channel, firstProperty: (.velocity, velocity), secondProperty: (.invalid, "0"))
    }
    
    
    public func message() -> String {
        var string = "\(type.string()), Channel \(channel),"
        switch type {
        case .noteOn, .noteOff, .controlChange, .keyPressure:
            string += " \(firstProperty.property.string()) \(firstProperty.value), \(secondProperty.property.string()) \(secondProperty.value)"
        case .programChange, .channelPressure, .pitchBendChange:
            string += " \(firstProperty.property.string()) \(firstProperty.value)"
        }
        return string
    }
    
    public func messageType() -> String {
        return "\(type.string())"
    }
    
    public func properties() -> [(property: String, value: Int)] {
        if secondProperty.property == .invalid {
            return [(firstProperty.property.string(), firstProperty.value)]
        } else {
            return [(firstProperty.property.string(), firstProperty.value), (secondProperty.property.string(), secondProperty.value)]
        }
    }
    

}
