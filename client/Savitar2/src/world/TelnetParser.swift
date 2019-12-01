//
//  TelnetParser.swift
//  Savitar2
//
//  Created by Jay Koutavas on 11/30/19.
//  Copyright © 2019 Heynow Software. All rights reserved.
//

import Foundation

// Based on the PowerPlant based LTelnetParser by Paul D. Ferguson

enum CommandsEnum: UInt8 {
    case escIS = 0
    case escTerminalType = 24
    case escSE = 240                        // end of subnegotiation
    case escNOP                             // no-operation
    case escDM                              // data mark (data stream portion of a Synch)
    case escBRK                             // break key
    case escIP                              // interrupt process
    case escAO                              // abort output
    case escAYT                             // are you there?
    case escEC                              // erase character
    case escEL                              // erase line
    case escGA                              // go ahead
    case escSB                              // begin subnegotiation
    case escWILL
    case escWONT
    case escDO
    case escDONT
    case escIAC                            // data byte 255
}

enum StateEnum                // a simple state machine
{
    case normalChar                         // interpret as character
    case gotIAC                             // received an IAC character
    case gotSB                              // in subnegotiation
    case gotWILL                            // received a WILL option
    case gotWONT                            // received a WONT option
    case gotDO                              // received a DO option
    case gotDONT                            // received a DONT option
    case gotIACinSB                         // received IAC while in SB
}

let kSubBufferMax = 80            // max size of subnegotiation buffer, plenty big (I hope)

let TERMINAL_TYPE_STRING = "ANSI"

struct TelnetParser {
    public var mEndpoint: Endpoint?

    private var mCommand: CommandsEnum
    private var mState: StateEnum

    private var mSubBuffer: [UInt8]
    private var mSubBufferIndex: Int

    private var mDidWont: [Bool]
    private var mDidDont: [Bool]

    init() {
        mCommand = CommandsEnum.escTerminalType
        mState = StateEnum.normalChar

        mSubBuffer = [UInt8](repeating: 0, count: kSubBufferMax)
        mSubBufferIndex = 0

        mDidWont = [Bool](repeating: false, count: 256)
        mDidDont = [Bool](repeating: false, count: 256)
    }

    // ---------------------------------------------------------------------------
    //        • IsTelnetByte
    //            This function returns false if the character is not part of
    //            the telnet protocol (i.e., a higher level protocol should
    //            process this byte), or true if this is part of the telnet
    //            protocol, in which case this class or a subclass will
    //            handle it.
    // ---------------------------------------------------------------------------
    public mutating func isTelnetByte(char: UInt8) -> Bool {
        switch mState {
        case .normalChar:
            if char == CommandsEnum.escIAC.rawValue {
                mState = .gotIAC
                return true
            }
            return false
        case .gotIAC, .gotIACinSB:
            return receivedIAC(command: CommandsEnum(rawValue: char)!) // TODO: there's probably a way to avoid the cast
        case .gotSB:
            if char == CommandsEnum.escIAC.rawValue {
                mState = .gotIACinSB
                mSubBuffer[mSubBufferIndex] = char
                mSubBufferIndex += 1
            }
        case .gotWILL:
            receivedWill(option: char)
            mState = .normalChar
        case .gotWONT:
            receivedWont(option: char)
            mState = .normalChar
        case .gotDO:
            receivedDo(option: char)
            mState = .normalChar
        case .gotDONT:
            receivedDont(option: char)
            mState = .normalChar
        }

        return true
    }

    // ---------------------------------------------------------------------------
    //        • receivedIAC
    // Respond to a Telnet [IAC command] sequence.
    // ---------------------------------------------------------------------------
    private mutating func receivedIAC(command: CommandsEnum) -> Bool {
        switch command {
        case .escSE:
            mSubBuffer[mSubBufferIndex] = 0
            mState = .normalChar
            var data = Data()
            if mCommand == .escTerminalType {
                data.append(CommandsEnum.escIAC.rawValue)
                data.append(CommandsEnum.escSB.rawValue)
                data.append(CommandsEnum.escTerminalType.rawValue)
                data.append(CommandsEnum.escIS.rawValue)
                data.append(string: TERMINAL_TYPE_STRING)
                data.append(CommandsEnum.escIAC.rawValue)
                data.append(CommandsEnum.escSE.rawValue)

                mEndpoint!.sendData(data: data)
            }
        case .escDM, .escNOP, .escBRK, .escIP, .escAO, .escAYT, .escEC, .escEL, .escGA:
            mState = .normalChar
        case .escSB:
            mState = .gotSB
            mSubBufferIndex = 0
        case .escWILL:
            mState = .gotWILL
        case .escWONT:
            mState = .gotWONT
        case .escDO:
            mState = .gotDO
        case .escDONT:
            mState = .gotDONT
        default:
            if mState == .gotIACinSB {
                // note that we store the subnegotation buffer inf, but never do anything with it
                mSubBuffer[mSubBufferIndex] = command.rawValue
                mSubBufferIndex += 1
                mState = .gotIAC
            } else {
                mState = .normalChar
                return false
            }
        }

        return true
    }

    // ---------------------------------------------------------------------------
    //        • receivedWill
    //        Respond to a Telnet [IAC WILL option] sequence.  Default action is
    //        to just send a "DONT" response using the ReceivedWont() function.
    // ---------------------------------------------------------------------------
    private mutating func receivedWill(option: UInt8) {
        receivedWont(option: option)
    }

    // ---------------------------------------------------------------------------
    //        • receivedWont
    //        Respond to a Telnet [IAC WONT option] sequence.  You must send
    //        a "DONT" response.
    // ---------------------------------------------------------------------------
    private mutating func receivedWont(option: UInt8) {
        if mDidDont[Int(option)] == false {
            var data = Data()
            data.append(CommandsEnum.escIAC.rawValue)
            data.append(CommandsEnum.escDONT.rawValue)
            data.append(option)

            mEndpoint!.sendData(data: data)
            mDidDont[Int(option)] = true
        }
    }

    // ---------------------------------------------------------------------------
    //        • receivedDo
    //        Respond to a Telnet [IAC DO option] sequence.  Default action is
    //        to just send a "WONT" response using the ReceivedDont() function.
    // ---------------------------------------------------------------------------
    private mutating func receivedDo(option: UInt8) {
        switch option {
        case CommandsEnum.escTerminalType.rawValue:
            mCommand = CommandsEnum.escTerminalType
            var data = Data()
            data.append(CommandsEnum.escIAC.rawValue)
            data.append(CommandsEnum.escWILL.rawValue)
            data.append(option)

            mEndpoint!.sendData(data: data)
        default:
            receivedDont(option: option)
        }
    }

    // ---------------------------------------------------------------------------
    //        • receivedDont
    //        Respond to a Telnet [IAC DONT option] sequence.  You must send
    //        a "WONT" response.
    // ---------------------------------------------------------------------------
    private mutating func receivedDont(option: UInt8) {
        if mDidWont[Int(option)] == false {
            var data = Data()
            data.append(CommandsEnum.escIAC.rawValue)
            data.append(CommandsEnum.escWONT.rawValue)
            data.append(option)

            mEndpoint!.sendData(data: data)
            mDidWont[Int(option)] = true
        }
    }
}
