//
//  MIDIParser.swift
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

import Foundation

public enum MIDIParserError: Error {
    case unrecognisedData
    case unableToDecodeString
    case incorrectTerminator
    case noSocket
    case cantConfirmDanglingESC
    case unrecognisedMIDIMessage
    case unableToParseMIDIShowControlMessage
    case unableToParseMIDITimecodeMessage
    case unableToParseMIDINoteMessage
    case notQuarterFrameData
}

extension String {
    /// An `NSRange` that represents the full range of the string.
    var nsrange: NSRange {
        return NSRange(location: 0, length: utf16.count)
    }
    
    func substring(with nsrange: NSRange) -> Substring? {
        guard let range = Range(nsrange, in: self) else { return nil }
        return self[range]
    }
    
    func hexadecimal() -> Data? {
        var data = Data(capacity: self.count / 2)
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, range: NSMakeRange(0, utf16.count)) { match, flags, stop in
            let byteString = (self as NSString).substring(with: match!.range)
            var num = UInt8(byteString, radix: 16)!
            data.append(&num, count: 1)
        }
        guard data.count > 0 else { return nil }
        return data
    }
}

// MARK: Parser

public class MIDIParser {
    
    private let timecodeQuarterFrame: UInt8 = 0xF1
    private let noteOnRegex = "^9([0-9a-f]) ([0-9a-f]|[0-7][0-9a-f]) ([0-9a-f]|[0-7][0-9a-f])$"
    private let noteOffRegex = "^8([0-9a-f]) ([0-9a-f]|[0-7][0-9a-f]) ([0-9a-f]|[0-7][0-9a-f])$"
    private let programChangeRegex = "^c([0-9a-f]) ([0-9a-f]|[0-7][0-9a-f])$"
    private let controlChangeRegex = "^b([0-9a-f]) ([0-9a-f]|[0-7][0-9a-f]) ([0-9a-f]|[0-7][0-9a-f])$"
    private let keyPressureRegex = "^a([0-9a-f]) ([0-9a-f]|[0-7][0-9a-f]) ([0-9a-f]|[0-7][0-9a-f])$"
    private let channelPressureRegex = "^d([0-9a-f]) ([0-9a-f]|[0-7][0-9a-f])$"
    private let pitchBendChangeRegex = "^e([0-9a-f]) ((?:[0-9a-f]|[0-7][0-9a-f]) (?:[0-9a-f]|[0-7][0-9a-f]))$"
    private let showControlRegex = "^f0 7f ([0-9a-f]|[0-7][1-9a-f]) (?:02|2) ([0-9a-f]|[0-7][1-9a-f]) ([0-9a-f]|[0-7][1-9a-f])(?:((?: 3[1-9])+(?: 2e(?: 3[1-9])*){0,1}))?(?: 0((?: 3[1-9])+(?: 2e(?: 3[1-9])*){0,1}))?(?: 0((?: 3[1-9])+(?: 2e(?: 3[1-9])*){0,1}))? (f7|00 f7)$"
    private let timecodeRegex = "^f1 [0-9a-f](?:[0-9a-f]?)"
    
    public func process(MIDIDate data: Data, from sender: MIDIServer, for destination: MIDIPacketDestination, with replySocket: Socket, and terminator: MIDIServer.Terminator) throws {
        if !data.isEmpty {
            if data.subdata(in: data.startIndex..<data.startIndex + 5 ) == Data([UInt8]("MIDI ".utf8)) {
                var newData = data.subdata(in: data.startIndex + 5..<data.count)
                switch terminator {
                case .none:
                    do {
                        try process(MIDIMessageString: newData,from: sender, for: destination, with: replySocket)
                    } catch {
                        throw error
                    }
                case .carriageReturn, .lineFeed:
                    if Data([newData.last!]) == Data([UInt8](terminator.rawValue.utf8)) {
                        do {
                            try process(MIDIMessageString: newData.subdata(in: newData.startIndex..<newData.endIndex - 1),from: sender, for: destination, with: replySocket)
                        } catch {
                            throw error
                        }
                    } else {
                        throw MIDIParserError.incorrectTerminator
                    }
                case .carriageReturnLineFeed:
                    if newData.subdata(in: newData.endIndex-2..<newData.count) == Data([UInt8](terminator.rawValue.utf8)) {
                        do {
                            try process(MIDIMessageString: newData.subdata(in: newData.startIndex..<newData.endIndex - 2),from: sender, for: destination, with: replySocket)
                        } catch {
                            throw error
                        }
                    } else {
                        throw MIDIParserError.incorrectTerminator
                    }
                }
            } else {
                throw MIDIParserError.unrecognisedData
            }
        }
    }
    
    private func isValidNoteOnMessage(message: String) -> Bool {
        // match string with case insensitive predicate
        print(message)
        let predicate = NSPredicate(format: "SELF MATCHES [c] %@", noteOnRegex)
        return predicate.evaluate(with: message)
    }
    
    private func isValidNoteOffMessage(message: String) -> Bool {
        // match string with case insensitive predicate
        let predicate = NSPredicate(format: "SELF MATCHES [c] %@", noteOffRegex)
        return predicate.evaluate(with: message)
    }
    
    private func isValidProgramChangeMessage(message: String) -> Bool {
        // match string with case insensitive predicate
        let predicate = NSPredicate(format: "SELF MATCHES [c] %@", programChangeRegex)
        return predicate.evaluate(with: message)
    }
    
    private func isValidControlChangeMessage(message: String) -> Bool {
        // match string with case insensitive predicate
        let predicate = NSPredicate(format: "SELF MATCHES [c] %@", controlChangeRegex)
        return predicate.evaluate(with: message)
    }
    
    private func isValidKeyPressureMessage(message: String) -> Bool {
        // match string with case insensitive predicate
        let predicate = NSPredicate(format: "SELF MATCHES [c] %@", keyPressureRegex)
        return predicate.evaluate(with: message)
    }
    
    private func isValidChannelPressureMessage(message: String) -> Bool {
        // match string with case insensitive predicate
        let predicate = NSPredicate(format: "SELF MATCHES [c] %@", channelPressureRegex)
        return predicate.evaluate(with: message)
    }
    
    private func isValidPitchBendChangeMessage(message: String) -> Bool {
        // match string with case insensitive predicate
        let predicate = NSPredicate(format: "SELF MATCHES [c] %@", pitchBendChangeRegex)
        return predicate.evaluate(with: message)
    }
    
    private func isValidMSC(message: String) -> Bool {
        // match string with case insensitive predicate
        let predicate = NSPredicate(format: "SELF MATCHES [c] %@", showControlRegex)
        return predicate.evaluate(with: message)
    }
    
    private func isValidTimecode(message: String) -> Bool {
        // match string with case insensitive predicate
        let predicate = NSPredicate(format: "SELF MATCHES [c] %@", timecodeRegex)
        return predicate.evaluate(with: message)
    }
    
    private func process(MIDIMessageString data: Data, from sender: MIDIServer, for destination: MIDIPacketDestination, with replySocket: Socket) throws {
        guard let string = String(data: data, encoding: .utf8) else {
            throw MIDIParserError.unableToDecodeString
        }
        if isValidTimecode(message: string) {
            do {
                try process(timecodeMessageString: string, from: sender, for: destination, with: replySocket)
            } catch {
                throw error
            }
        } else if isValidMSC(message: string) {
            do {
                try process(mscMessageString: string, for: destination, with: replySocket)
            } catch {
                throw error
            }
        } else if isValidNoteOnMessage(message: string) {
            do {
                try process(noteOnMessageString: string, for: destination, with: replySocket)
            } catch {
                throw error
            }
        }  else if isValidNoteOffMessage(message: string) {
            do {
                try process(noteOffMessageString: string, for: destination, with: replySocket)
            } catch {
                throw error
            }
        } else if isValidProgramChangeMessage(message: string) {
            do {
                try process(programChangeMessageString: string, for: destination, with: replySocket)
            } catch {
                throw error
            }
        } else if isValidControlChangeMessage(message: string) {
            do {
                try process(controlChangeMessageString: string, for: destination, with: replySocket)
            } catch {
                throw error
            }
        } else if isValidKeyPressureMessage(message: string) {
            do {
                try process(keyPressureMessageString: string, for: destination, with: replySocket)
            } catch {
                throw error
            }
        } else if isValidChannelPressureMessage(message: string) {
            do {
                try process(channelPressureMessageString: string, for: destination, with: replySocket)
            } catch {
                throw error
            }
        } else if isValidPitchBendChangeMessage(message: string) {
            do {
                try process(pitchBendChangeMessageString: string, for: destination, with: replySocket)
            } catch {
                throw error
            }
        } else {
            throw MIDIParserError.unrecognisedMIDIMessage
        }
    }
    
    private func process(noteOnMessageString string: String, for destination: MIDIPacketDestination, with replySocket: Socket) throws {
        let regularExpression = try NSRegularExpression(pattern: noteOnRegex, options: [.caseInsensitive])
        let matches = regularExpression.matches(in: string, options: [], range: string.nsrange)
        // There should only be one match. Range at index 1 will always be the channel. Range at index 2 will always be the Note Number, Range at index 3 will always be the Velocity.
        guard let match = matches.first, match.range == string.nsrange, let channel = string.substring(with: match.range(at: 1)), let noteNumber = string.substring(with: match.range(at: 2)), let velocity = string.substring(with: match.range(at: 3)) else { throw MIDIParserError.unableToParseMIDINoteMessage }
        let message = MIDIVoiceMessage(noteOnWithChannel: String(channel), noteNumber: String(noteNumber), andVelocity: String(velocity))
        destination.take(voiceMessage: message)
    }
    
    private func process(noteOffMessageString string: String, for destination: MIDIPacketDestination, with replySocket: Socket) throws {
        let regularExpression = try NSRegularExpression(pattern: noteOffRegex, options: [.caseInsensitive])
        let matches = regularExpression.matches(in: string, options: [], range: string.nsrange)
        // There should only be one match. Range at index 1 will always be the channel. Range at index 2 will always be the Note Number, Range at index 3 will always be the Velocity.
        guard let match = matches.first, match.range == string.nsrange, let channel = string.substring(with: match.range(at: 1)), let noteNumber = string.substring(with: match.range(at: 2)), let velocity = string.substring(with: match.range(at: 3)) else { throw MIDIParserError.unableToParseMIDINoteMessage }
        let message = MIDIVoiceMessage(noteOffWithChannel: String(channel), noteNumber: String(noteNumber), andVelocity: String(velocity))
        destination.take(voiceMessage: message)
    }
    
    private func process(programChangeMessageString string: String, for destination: MIDIPacketDestination, with replySocket: Socket) throws {
        let regularExpression = try NSRegularExpression(pattern: programChangeRegex, options: [.caseInsensitive])
        let matches = regularExpression.matches(in: string, options: [], range: string.nsrange)
        // There should only be one match. Range at index 1 will always be the channel. Range at index 2 will always be the Program Number.
        guard let match = matches.first, match.range == string.nsrange, let channel = string.substring(with: match.range(at: 1)), let programNumber = string.substring(with: match.range(at: 2)) else { throw MIDIParserError.unableToParseMIDINoteMessage }
        let message = MIDIVoiceMessage(programChangeWithChannel: String(channel), andProgramNumber: String(programNumber))
        destination.take(voiceMessage: message)
    }
    
    private func process(controlChangeMessageString string: String, for destination: MIDIPacketDestination, with replySocket: Socket) throws {
        let regularExpression = try NSRegularExpression(pattern: controlChangeRegex, options: [.caseInsensitive])
        let matches = regularExpression.matches(in: string, options: [], range: string.nsrange)
        // There should only be one match. Range at index 1 will always be the channel. Range at index 2 will always be the Control Number, Range at index 3 will always be the Control Value.
        guard let match = matches.first, match.range == string.nsrange, let channel = string.substring(with: match.range(at: 1)), let controlNumber = string.substring(with: match.range(at: 2)), let controlValue = string.substring(with: match.range(at: 3)) else { throw MIDIParserError.unableToParseMIDINoteMessage }
        let message = MIDIVoiceMessage(controlChangeWithChannel: String(channel), controlNumber: String(controlNumber), andControlValue: String(controlValue))
        destination.take(voiceMessage: message)
    }
    
    private func process(keyPressureMessageString string: String, for destination: MIDIPacketDestination, with replySocket: Socket) throws {
        let regularExpression = try NSRegularExpression(pattern: keyPressureRegex, options: [.caseInsensitive])
        let matches = regularExpression.matches(in: string, options: [], range: string.nsrange)
        // There should only be one match. Range at index 1 will always be the channel. Range at index 2 will always be the Note Number, Range at index 3 will always be the Pressure Value.
        guard let match = matches.first, match.range == string.nsrange, let channel = string.substring(with: match.range(at: 1)), let noteNumber = string.substring(with: match.range(at: 2)), let pressureValue = string.substring(with: match.range(at: 3)) else { throw MIDIParserError.unableToParseMIDINoteMessage }
        let message = MIDIVoiceMessage(keyPressureWithChannel: String(channel), noteNumber: String(noteNumber), andPressureValue: String(pressureValue))
        destination.take(voiceMessage: message)
    }
    
    private func process(channelPressureMessageString string: String, for destination: MIDIPacketDestination, with replySocket: Socket) throws {
        let regularExpression = try NSRegularExpression(pattern: channelPressureRegex, options: [.caseInsensitive])
        let matches = regularExpression.matches(in: string, options: [], range: string.nsrange)
        // There should only be one match. Range at index 1 will always be the channel. Range at index 2 will always be the Pressure Value.
        guard let match = matches.first, match.range == string.nsrange, let channel = string.substring(with: match.range(at: 1)), let pressureValue = string.substring(with: match.range(at: 2)) else { throw MIDIParserError.unableToParseMIDINoteMessage }
        let message = MIDIVoiceMessage(channelPressureWithChannel: String(channel), andPressureValue: String(pressureValue))
        destination.take(voiceMessage: message)
    }
    
    private func process(pitchBendChangeMessageString string: String, for destination: MIDIPacketDestination, with replySocket: Socket) throws {
        let regularExpression = try NSRegularExpression(pattern: pitchBendChangeRegex, options: [.caseInsensitive])
        let matches = regularExpression.matches(in: string, options: [], range: string.nsrange)
        // There should only be one match. Range at index 1 will always be the channel. Range at index 2 will always be the Velocity as two bytes.
        guard let match = matches.first, match.range == string.nsrange, let channel = string.substring(with: match.range(at: 1)), let velocitySubString = string.substring(with: match.range(at: 2)), let hexData = String(velocitySubString).hexadecimal(), let lsb = hexData.first, let msb = hexData.last else { throw MIDIParserError.unableToParseMIDINoteMessage }
            // Shift & Cast the Most Significant Byte.
            let shiftedMSB = UInt16(msb) << 7
            // Bitwise OR the MSB and LSB (Casting the Least Significant Bit to 16 as well)
            let velocity = shiftedMSB | UInt16(lsb)
            let rangedVelocity: Int16 = Int16(velocity) - 8192
        let message = MIDIVoiceMessage(pitchBendChangeWithChannel: String(channel), andVelocity: String(rangedVelocity))
        destination.take(voiceMessage: message)
    }
    
    private func double(fromHexString string: Substring) -> Double {
        let components = string.components(separatedBy: " ")
        var cueNumber = ""
        for element in components {
            if let number = element.last, element.first == "3" {
                cueNumber += "\(number)"
            }
            if element == "2E" || element == "2e" {
                cueNumber += "."
            }
        }
        guard let number = Double(cueNumber) else { return 0 }
        return number
    }
    
    private func process(mscMessageString string: String, for destination: MIDIPacketDestination, with replySocket: Socket) throws {
        do {
            let regularExpression = try NSRegularExpression(pattern: showControlRegex, options: [.caseInsensitive])
            let matches = regularExpression.matches(in: string, options: [], range: string.nsrange)
            // There should only be one match. Range at index 1 will always be the device ID. Range at index 2 will always be the Command Format, Range at index 3 will always be the Command. If there are ranges at index 4,5 & 6 these are Cue Number, Cue List, Cue Path, respectively.
            guard let match = matches.first, match.range == string.nsrange, let deviceID = string.substring(with: match.range(at: 1)), let commandFormat = string.substring(with: match.range(at: 2)), let command = string.substring(with: match.range(at: 3)) else { throw MIDIParserError.unableToParseMIDIShowControlMessage }
            var list = 0.0
            var cue = 0.0
            var path = 0.0
            if let match = matches.first, let cueNumber = string.substring(with: match.range(at: 4)) {
                cue = double(fromHexString: cueNumber)
            }
            if let match = matches.first, let cueList = string.substring(with: match.range(at: 5)) {
                list = double(fromHexString: cueList)
            }
            if let match = matches.first, let cuePath = string.substring(with: match.range(at: 6)) {
                path = double(fromHexString: cuePath)
            }
            let message = MIDIShowControlMessage(hexDeviceID: String(deviceID), hexCommandFormat: String(commandFormat), hexCommand: String(command), cue: cue, list: list, path: path)
            destination.take(showControlMessage: message)
        } catch {
            throw MIDIParserError.unableToParseMIDIShowControlMessage
        }
    }
    
    private func process(timecodeMessageString string: String, from sender: MIDIServer, for destination: MIDIPacketDestination, with replySocket: Socket) throws {
        guard let hexData = string.hexadecimal(), hexData.first == timecodeQuarterFrame else {
            throw MIDIParserError.unableToParseMIDITimecodeMessage
        }
        let quarterFrame = hexData[1] >> 4
        switch quarterFrame {
        case 0: set(sender: sender, lowF: hexData[1])
        case 1: set(sender: sender, highF: hexData[1])
        case 2: set(sender: sender, lowS: hexData[1])
        case 3: set(sender: sender, highS: hexData[1])
        case 4: set(sender: sender, lowM: hexData[1])
        case 5: set(sender: sender, highM: hexData[1])
        case 6: set(sender: sender, lowH: hexData[1])
        case 7: set(sender: sender, highH: hexData[1])
        default: break
        }
    }
    
    public func set(sender: MIDIServer, highH: UInt8) {
        // h = (h & 0000 1111) | ((highH & 0000 0001) Shift Left 4: (???? 0000))
        sender.h = (sender.h & 0x0F) | ((highH & 0x01) << 4)
        sender.tcMode = (Int8((highH & 0x06) >> 1))
        sender.f += 1
        // validMask Bitwise OR and Assign 1000 0000
        sender.validMask |= 0x80
        sender.newFrameReceived()
    }
    
    public func set(sender: MIDIServer, lowH: UInt8) {
        // h = (h & 1111 0000) | (lowH & 0000 1111)
        sender.h = (sender.h & 0xF0) | (lowH & 0x0F)
        // validMask Bitwise OR and Assign 0100 0000
        sender.validMask |= 0x40
    }
    
    public func set(sender: MIDIServer, highM: UInt8) {
        // m = (m & 0000 1111) | ((highM & 0000 1111) Shift Left 4: (???? 0000))
        sender.m = (sender.m & 0x0F) | ((highM & 0x0F) << 4)
        // validMask Bitwise OR and Assign 0010 0000
        sender.validMask |= 0x20
    }
    
    public func set(sender: MIDIServer, lowM: UInt8) {
        // m = (m & 1111 0000) | (lowM & 0000 1111)
        sender.m = (sender.m & 0xF0) | (lowM & 0x0F)
        // validMask Bitwise OR and Assign 0001 0000
        sender.validMask |= 0x10
    }
    
    public func set(sender: MIDIServer, highS: UInt8) {
        // s = (s & 0000 1111) | ((highS & 0000 1111) Shift Left 4: (???? 0000))
        sender.s = (sender.s & 0x0F) | ((highS & 0x0F) << 4)
        if (sender.s == 0 && (sender.f == 0 || (sender.f == 2 && sender.tcMode == MIDIDictionary.MTCFrameRate.df30.rawValue))) {
            // Update the minutes so it actually show's correctly, otherwise it'll be wrong for 2 frames/untill the minutes frames are received.
            sender.m += 1
        }
        // validMask Bitwise OR and Assign 0000 1000
        sender.validMask |= 0x8
        sender.newFrameReceived()
    }
    
    public func set(sender: MIDIServer, lowS: UInt8) {
        // s = (s & 1111 0000) | (lowS & 0000 1111)
        sender.s = (sender.s & 0xF0) | (lowS & 0x0F)
        // validMask Bitwise OR and Assign 0000 0100
        sender.validMask |= 0x4
    }
    
    public func set(sender: MIDIServer, highF: UInt8) {
        // f = (f & 0000 1111) | ((highF & 0000 1111) Shift Left 4: (???? 0000))
        sender.f = (sender.f & 0x0F) | ((highF & 0x0F) << 4)
        // validMask Bitwise OR and Assign 0000 0010
        sender.validMask |= 0x2
    }
    
    public func set(sender: MIDIServer, lowF: UInt8) {
        // f = (f & 1111 0000) | (lowF & 0000 1111)
        sender.f = (sender.f & 0xF0) | (lowF & 0x0F)
        // validMask Bitwise OR and Assign 0000 0001
        sender.validMask |= 0x1
    }
}
