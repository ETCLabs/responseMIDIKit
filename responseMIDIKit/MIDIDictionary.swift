//
//  MIDIDictionary.swift
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

final class MIDIDictionary {
    
    public enum messageType: Int {
        case MIDIShowControl = 0
        case MIDIVoiceMessage = 1
        case MIDITimecode = 2
    }
    
    public enum MIDIShowControlComandFormats: Int {
        case AllTypes, Lighting, MovingLights, ColorChanges, Strobes, Lasers, Chasers, Sound, Music, CDPlayers, EPROMPlayback, AudioTapeMachines, Intercoms, Amplifiers, AudioEffectsDevices, Equalizers, Machinery, Rigging, Flys, Lifts, Turntables, Trusses, Robots, Animation, Floats, Breakaways, Barges, Video, VideoTapeMachines, VideoCassetteMachines, VideoDiscPlayers, VideoSwitches, VideoEffects, VideoCharacterGeneraters, VideoStillStores, VideoMonitors, Projection, FilmProjectors, SlideProjectors, VideoProjectors, Dissolvers, ShutterControls, ProcessControl, HydraulicOil, H20, C02, CompressedAir, NaturalGas, Fog, Smoke, CrackedHaze, Pyrotechnics, Fireworks, Explosions, Flame, SmokePots
        
        static let commandFormats = [
            AllTypes: "All Types", Lighting : "Lighting (General)", MovingLights : "Moving Lights", ColorChanges : "Color Changes", Strobes : "Strobes", Lasers : "Lasers",Chasers : "Chasers", Sound: "Sound (General)",Music: "Music", CDPlayers: "CD Players", EPROMPlayback: "EPROM Playback", AudioTapeMachines: "Audio Tape Machine", Intercoms: "Intercoms", Amplifiers: "Amplifiers", AudioEffectsDevices: "Audio Effects Devices", Equalizers: "Equaliziers", Machinery: "Machinery (General)", Rigging: "Rigging", Flys: "Flys", Lifts: "Lifts", Turntables: "Turntables", Trusses: "Trusses", Robots: "Robots", Animation: "Animation", Floats: "Floats", Breakaways: "Breakaways", Barges: "Barges", Video: "Video (General)", VideoTapeMachines: "Video Tape Machines", VideoCassetteMachines: "Video Cassette Machines", VideoDiscPlayers: "Video Disc Players", VideoSwitches: "Video Switches", VideoEffects: "Video Effects", VideoCharacterGeneraters: "Video Character Generators", VideoStillStores: "Video Still Store", VideoMonitors: "Video Monitors", Projection: "Projection (General)", FilmProjectors: "Film Projectors", SlideProjectors: "Slide Projectors", VideoProjectors: "Video Projectors", Dissolvers: "Dissolvers", ShutterControls: "Shutter Controls", ProcessControl: "Process Control (General)", HydraulicOil: "Hydraulic Oil", H20: "H2O", C02: "CO2", CompressedAir: "Compressed Air", NaturalGas: "Natural Gas", Fog: "Fog", Smoke: "Smoke", CrackedHaze: "Cracked Haze", Pyrotechnics: "Pyrotechnics (General)", Fireworks: "Fireworks", Explosions: "Explosions", Flame: "Flame", SmokePots: "Smoke Pots"]
        
        func commandFormat() -> String {
            if let commandFormat = MIDIShowControlComandFormats.commandFormats[self] {
                return commandFormat
            } else {
                return "Unknown Command Format"
            }
        }
        
        static let hexValues = [
            AllTypes: "7F", Lighting : "01", MovingLights : "02", ColorChanges : "03", Strobes : "04", Lasers : "05",Chasers : "06", Sound: "10",Music: "11", CDPlayers: "12", EPROMPlayback: "13", AudioTapeMachines: "14", Intercoms: "15", Amplifiers: "16", AudioEffectsDevices: "17", Equalizers: "18", Machinery: "20", Rigging: "21", Flys: "22", Lifts: "23", Turntables: "24", Trusses: "25", Robots: "26", Animation: "27", Floats: "28", Breakaways: "29", Barges: "2A", Video: "30", VideoTapeMachines: "31", VideoCassetteMachines: "32", VideoDiscPlayers: "33", VideoSwitches: "34", VideoEffects: "35", VideoCharacterGeneraters: "36", VideoStillStores: "37", VideoMonitors: "38", Projection: "40", FilmProjectors: "41", SlideProjectors: "42", VideoProjectors: "43", Dissolvers: "44", ShutterControls: "45", ProcessControl: "50", HydraulicOil: "51", H20: "52", C02: "53", CompressedAir: "54", NaturalGas: "55", Fog: "56", Smoke: "57", CrackedHaze: "58", Pyrotechnics: "60", Fireworks: "61", Explosions: "62", Flame: "63", SmokePots: "64"]
        
        func hex() -> String {
            if let hex = MIDIShowControlComandFormats.hexValues[self] {
                return hex
            } else {
                return "Unknown Hex Value"
            }
        }
        
        static let allValues = [AllTypes, Lighting, MovingLights, ColorChanges, Strobes, Lasers, Chasers, Sound, Music, CDPlayers, EPROMPlayback, AudioTapeMachines, Intercoms, Amplifiers, AudioEffectsDevices, Equalizers, Machinery, Rigging, Flys, Lifts, Turntables, Trusses, Robots, Animation, Floats, Breakaways, Barges, Video, VideoTapeMachines, VideoCassetteMachines, VideoDiscPlayers, VideoSwitches, VideoEffects, VideoCharacterGeneraters, VideoStillStores, VideoMonitors, Projection, FilmProjectors, SlideProjectors, VideoProjectors, Dissolvers, ShutterControls, ProcessControl, HydraulicOil, H20, C02, CompressedAir, NaturalGas, Fog, Smoke, CrackedHaze, Pyrotechnics, Fireworks, Explosions, Flame, SmokePots]
    }
    
    public enum MIDIShowControlComands: Int {
        case Go, Stop, Resume, TimedGo, Load, Set, Fire, AllOff, Restore, Reset, GoOff, GoJamClock, StandbyPlus, StandbyMinus, SequencePlus, SequenceMinus, StartClock, StopClock, ZeroClock, SetClock, MTCChaseOn, MTCChaseOff, OpenCueList, CloseCueList, OpenCuePath, CloseCuePath
        
        static let commands = [
            Go: "GO", Stop: "STOP", Resume: "RESUME", TimedGo: "TIMED_GO", Load: "LOAD", Set: "SET", Fire: "FIRE", AllOff: "ALL_OFF", Restore: "RESTORE", Reset: "RESET", GoOff: "GO_OFF", GoJamClock: "GO/JAM_CLOCK", StandbyPlus: "STANDBY_+", StandbyMinus: "STANBY_-", SequencePlus: "SEQUENCE_+", SequenceMinus: "SEQUENCE_-", StartClock: "START_CLOCK", StopClock: "STOP_CLOCK", ZeroClock: "ZERO_CLOCK", SetClock: "SET_CLOCK", MTCChaseOn: "MTC_CHASE_ON", MTCChaseOff: "MTC_CHASE_OFF", OpenCueList: "OPEN_CUE_LIST", CloseCueList: "CLOSE_CUE_LIST", OpenCuePath: "OPEN_CUE_PATH", CloseCuePath: "CLOSE_CUE_PATH"]
        
        func command() -> String {
            if let commands = MIDIShowControlComands.commands[self] {
                return commands
            } else {
                return "Unknown Command"
            }
        }
        
        static let hexValues = [
            Go: "01", Stop: "02", Resume: "03", TimedGo: "04", Load: "05", Set: "06", Fire: "07", AllOff: "08", Restore: "09", Reset: "0A", GoOff: "0B", GoJamClock: "10", StandbyPlus: "11", StandbyMinus: "12", SequencePlus: "13", SequenceMinus: "14", StartClock: "15", StopClock: "16", ZeroClock: "17", SetClock: "18", MTCChaseOn: "19", MTCChaseOff: "1A", OpenCueList: "1B", CloseCueList: "1C", OpenCuePath: "1D", CloseCuePath: "1E"]
        
        func hex() -> String {
            if let hex = MIDIShowControlComands.hexValues[self] {
                return hex
            } else {
                return "Unknown Hex Value"
            }
        }
        
        static let allValues = [Go, Stop, Resume, TimedGo, Load, Set, Fire, AllOff, Restore, Reset, GoOff, GoJamClock, StandbyPlus, StandbyMinus, SequencePlus, SequenceMinus, StartClock, StopClock, ZeroClock, SetClock, MTCChaseOn, MTCChaseOff, OpenCueList, CloseCueList, OpenCuePath, CloseCuePath]
    }
    
    public enum MTCFrameRate: Int8 {
        case fps24 = 0 // 24 Frames Per Second
        case fps25 = 1 // 25 Frames Per Second
        case df30 = 2 // 30 Frames Per Second Drop Frame
        case nd30 = 3 // 30 Frames Per Second Non Drop
        case invalid = -1 // Invalid
        
        static let strings = [fps24: "24 fps", fps25: "25 fps", df30: "30fps drop", nd30: "30fps non-drop", invalid: "Unknown framerate"]
        
        func string() -> String {
            if let string = MTCFrameRate.strings[self] {
                return string
            } else {
                return "Unknown String"
            }
        }
    }
    
    public enum MIDIVoiceMessageType {
        case noteOn
        case noteOff
        case programChange
        case controlChange
        case keyPressure
        case channelPressure
        case pitchBendChange
        
        static let strings = [noteOn: "Note On", noteOff: "Note Off", programChange: "Program Change", controlChange: "Control Change", keyPressure: "Key Pressure (Aftertouch)", channelPressure: "Channel Pressure", pitchBendChange: "Pitch Bend Change"]
        
        func string() -> String {
            if let string = MIDIVoiceMessageType.strings[self] {
                return string
            } else {
                return "Unknown String"
            }
        }
    }
    
    public enum MIDIVoiceMessageProperty {
        case noteNumber
        case velocity
        case programNumber
        case controlNumber
        case controlValue
        case pressureValue
        case invalid
    
        static let strings = [noteNumber: "Note Number", velocity: "Velocity", programNumber: "Program Number", controlNumber: "Control Number", controlValue: "Control Value", pressureValue: "Pressure Value", invalid: "Unknown Property"]
        
        func string() -> String {
            if let string = MIDIVoiceMessageProperty.strings[self] {
                return string
            } else {
                return "Unknown String"
            }
        }
        
    }
    
    
    
}


