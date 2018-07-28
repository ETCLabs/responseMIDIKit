# responseMIDIKit
UNOFFICIAL - A Swift framework for receiving and parsing UDP String MIDI messages from ETC's Response MIDI Gateway hardware.

For convenience, I've included a few public domain source files, Thanks and curiosity should rightfully be directed towards them:

[CocoaAsyncSocket](https://github.com/robbiehanson/CocoaAsyncSocket).  
[Swift-Netutils](https://github.com/svdo/swift-netutils).

## Response Time

Inluded is a small demo app "Response Time"

## Quick Start
### MIDI Server
#### Step 1
Import responseMIDIKit framework into your project
```swift
import responseMIDIKit
```
#### Step 2
Create Server
```swift
let server = MIDIServer()
server.interface = "en0"
server.port = 24601
server.terminator = .carriageReturnLineFeed
```
#### Step 3
Conform to the MIDI Packet Destination Protocol   

```swift    
    func take(timecodeMessage: MIDITimecodeMessage) {
        print("\(timecodeMessage.timecode()) \(timecodeMessage.framerate())")
    }
    
    func take(showControlMessage: MIDIShowControlMessage) {
        print(showControlMessage.message())
    }
    
    func take(voiceMessage: MIDIVoiceMessage) {
        print(voiceMessage.message())
    }
```  

#### Step 4
Start Listening 

```swift  
    do {
        try server.startListening()
    } catch let error as NSError {
        printerror.localizedDescription)
    }
``` 
