//
//  TelnetParser.swift
//  Savitar2
//
//  Created by Jay Koutavas on 11/30/19.
//  Copyright © 2019 Heynow Software. All rights reserved.
//

import Foundation
import Logging

// A Swift rewrite of the PowerPlant-based LTelnetParser by Paul D. Ferguson.
// Here are his original header comments:

// ===========================================================================
//    LTelnetParser.cp    ©1996 Paul D. Ferguson. All rights reserved.
//                            fergy@best.com
//
// A very rudimentary telnet implementation for PowerPlant's networking
// classes.  I wrote this so that PowerTelnet could actually do a telnet
// session (what a concept!)
//
// ••••••• NOTE ••• NOTE ••• NOTE ••• NOTE ••• NOTE ••• NOTE ••• NOTE •••••••
//
// This class is unsupported and virtually untested.  Use at your own risk.
// If you find bugs in it, please let me know at the email address above.
//
// I cannot provide any support for these classes.  If you are unfamiliar
// with telnet, I suggest you visit your local bookstore or search the Web
// for information about how telnet works and about the various negotiations
// and subnegotiations that telnet implements.  Just please don't ask me,
// because I don't know!
//
//
// Theory of operation
// -------------------
// This class does no telnet protocols, it defaults to refusing any DO
// requests, and negating any WILL requests.  If you have more sophisticated
// telnet needs, you can override or modify this class accordingly.
//
// To use this class with PowerTelnet, do the following (this description is
// for the threads implementation):
//
// (1) in CTelnetViaThreads.h, add a LTelnetParser member object to
//     CTelnetClientThread:
//
//            LTelnetParser    mTelnetParser;
//
// (2) in the CTelnetClientThread::CTelnetClientThread initializer list, add:
//
//            mTelnetParser(inNetworkEndpoint),
//
// (3) in the while loop in CTelnetThread::Run, add this if() clause:
//
//            if (mTelnetParser.IsTelnetByte(theChar) == false)
//                mTerminalPane->DoWriteChar(theChar);
//
// The steps for the event loop version of PowerTelnet are similar, but have
// one important difference due to how the classes are created:
//
// (1) add a member object to CTelnetViaEventLoop
//
//            LTelnetParser        mTelnetParser;
//
// (2) in CTelnetViaEventLoop::Connect, add the statement:
//
//            mTelnetParser.SetEndpoint(mEndpoint);
//
// (3) munge CTelnetViaEventLoop::AcceptText to iterate through the text
//     buffer and call mTelnetParser.IsTelnetByte() for each byte.  This
//     is left as an exercise for you.
//
// ===========================================================================
//

enum CommandsEnum: UInt8 {
    case escIS = 0
    case escTerminalType = 24
    case escSE = 240 // end of subnegotiation
    case escNOP // no-operation
    case escDM // data mark (data stream portion of a Synch)
    case escBRK // break key
    case escIP // interrupt process
    case escAO // abort output
    case escAYT // are you there?
    case escEC // erase character
    case escEL // erase line
    case escGA // go ahead
    case escSB // begin subnegotiation
    case escWILL
    case escWONT
    case escDO
    case escDONT
    case escIAC // data byte 255
}

enum StateEnum // a simple state machine
{
    case normalChar // interpret as character
    case gotIAC // received an IAC character
    case gotSB // in subnegotiation
    case gotWILL // received a WILL option
    case gotWONT // received a WONT option
    case gotDO // received a DO option
    case gotDONT // received a DONT option
    case gotIACinSB // received IAC while in SB
}

let kSubBufferMax = 80 // max size of subnegotiation buffer, plenty big (I hope)

let TERMINAL_TYPE_STRING = "ANSI"

struct TelnetParser {
    // these get set by the user of TelnetParser
    public var mEndpoint: Session?
    public var logger: Logger?

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
            logger?.info("sub-buffer got its SE. len=\(mSubBufferIndex)")
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
                logger?.info("Sent TERMINAL-TYPE \(TERMINAL_TYPE_STRING)")
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
                logger?.info("sub-buffer got an IAC. len=\(mSubBufferIndex)")
            } else {
                // for case of escIAC escIAC
                mState = .normalChar
                return false // pass second escIAC to higher level protocol
            }
        }

        return true // for most cases, this byte is a part of the telnet protocol
    }

    // ---------------------------------------------------------------------------
    //        • receivedWill
    //        Respond to a Telnet [IAC WILL option] sequence.  Default action is
    //        to just send a "DONT" response using the ReceivedWont() function.
    // ---------------------------------------------------------------------------
    private mutating func receivedWill(option: UInt8) {
        telnetLog(message: "ReceivedWill", option: option)
        if option == 1 /* echo */ {
            receivedDo(option: option)
        } else {
            receivedWont(option: option)
        }
    }

    // ---------------------------------------------------------------------------
    //        • receivedWont
    //        Respond to a Telnet [IAC WONT option] sequence.  You must send
    //        a "DONT" response.
    // ---------------------------------------------------------------------------
    private mutating func receivedWont(option: UInt8) {
        telnetLog(message: "ReceivedWont", option: option)
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
        telnetLog(message: "ReceivedDo", option: option)
        switch option {
        case CommandsEnum.escTerminalType.rawValue:
            mCommand = CommandsEnum.escTerminalType
            var data = Data()
            data.append(CommandsEnum.escIAC.rawValue)
            data.append(CommandsEnum.escWILL.rawValue)
            data.append(option)

            mEndpoint!.sendData(data: data)
            telnetLog(message: "SentWill", option: option)
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

    private func telnetLog(message: String, option: UInt8) {
        #if DEBUG_TELNET
            var label: String
            switch option {
            case 0:
                label = "binary xfer"
            case 1:
                label = "local echo"
            case 3:
                label = "go ahead"
            case 5:
                label = "status"
            case 24:
                label = "term type"
            case 31:
                label = "window size"
            case 32:
                label = "term speed"
            case 33:
                label = "remote flow"
            case 34:
                label = "line mode"
            case 37:
                label = "authentication"
            case 38:
                label = "encryption"
            default:
                label = String(option)
            }
            logger?.info("\(message) \(label)")
        #endif
    }
}
