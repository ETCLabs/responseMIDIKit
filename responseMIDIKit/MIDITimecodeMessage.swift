//
//  MIDITimecodeMessage.swift
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

public class MIDITimecodeMessage: MIDIPacket {
    
    public let h: UInt8
    public let m: UInt8
    public let s: UInt8
    public let f: UInt8
    private let rate: Int8
    
    public init(hour: UInt8, minute: UInt8, second: UInt8, frame: UInt8, frameRate: Int8) {
        self.h = hour
        self.m = minute
        self.s = second
        self.f = frame
        self.rate = frameRate
    }
    
    public func timecode() -> String {
        var string = ""
        if h < 10 {
            string.append("\(0)\(h):")
        } else {
            string.append("\(h):")
        }
        if m < 10 {
            string.append("\(0)\(m):")
        } else {
            string.append("\(m):")
        }
        if s < 10 {
            string.append("\(0)\(s):")
        } else {
            string.append("\(s):")
        }
        if f < 10 {
            string.append("\(0)\(f)")
        } else {
            string.append("\(f)")
        }
        return string
    }
    
    public func framerate() -> String {
        switch rate {
        case MIDIDictionary.MTCFrameRate.fps24.rawValue:
            return MIDIDictionary.MTCFrameRate.fps24.string()
        case MIDIDictionary.MTCFrameRate.fps25.rawValue:
            return MIDIDictionary.MTCFrameRate.fps25.string()
        case MIDIDictionary.MTCFrameRate.df30.rawValue:
            return MIDIDictionary.MTCFrameRate.df30.string()
        case MIDIDictionary.MTCFrameRate.nd30.rawValue:
            return MIDIDictionary.MTCFrameRate.nd30.string()
        default:
            return "Invalid"
        }
    }
    
}
