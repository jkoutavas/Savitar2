//
//  Ansi2HtmlParser.swift
//  Savitar2
//
//  Created by Jay Koutavas on 11/6/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

// This is based on aha, by theZiz, https://github.com/theZiz/aha

import Foundation

enum ColorMode {
    case MODE_3BIT
    case MODE_8BIT
    case MODE_24BIT
}

struct State: Equatable {
    var fc = -1 //Standard Foreground Color //IRC-Color+8
    var bc = -1 //Standard Background Color //IRC-Color+8
    var bold = false
    var italic = false
    var underline = false
    var blink = false
    var crossedout = false
    var fc_colormode: ColorMode = .MODE_3BIT
    var bc_colormode: ColorMode = .MODE_3BIT
    var highlighted = false // for fc AND bc although not correct
}

typealias Digit = UInt8

struct Selem {
    var digit = [Digit]()
    var value = 0

    init(digit: [Digit], value: Int) {
        self.digit = digit
        self.value = value
    }
}

let fcstyle = [
    "dimgray",
    "red",
    "green",
    "yellow",
    "blue",
    "cyan",
    "white",
    "inverted",
    "reset"
]

func parseInsert(_ buffer: String) -> [Selem] {
    var momelem = [Selem]()

    var digit = [Digit]()
    var value = 0

    for (pos, char) in buffer.enumerated() {
        if char == "[" {
            continue
        }
        if char==";" || char==":" || pos == buffer.count-1 {
            if digit.count == 0 {
                digit.append(0)
            }
            momelem.append(Selem(digit: digit, value: value))
            digit.removeAll()
            value = 0
        } else {
            digit.append(Digit(String(char)) ?? 0)
            value = (value*10) + Int(digit.last ?? 0)
        }
    }
    return momelem
}

func swapColors(_ state: inout State) {
    if state.bc_colormode == .MODE_3BIT && state.bc == -1 {
        state.bc = 8
    }

    if state.fc_colormode == .MODE_3BIT && state.fc == -1 {
        state.fc = 9
    }

    swap(&state.bc, &state.fc)
    swap(&state.bc_colormode, &state.fc_colormode)
}

func updateColor(state: inout State, negative: Bool, color: Int) {
    if negative {
        state.bc = color
    } else {
        state.fc = color
    }
}

func updateColorState(momelem: inout Int, elems: [Selem], state: inout State, negative: Bool,
                      val1: Int, val2: Int, val3: Int, colorOffset: Int) {
    if elems[momelem].value == val1 &&
       elems.count - momelem > 1 &&
       elems[momelem+1].value == val2 { // 38;5;<n> -> 8 Bit
        momelem += 2
        state.fc_colormode = .MODE_8BIT
        let value = elems[momelem].value
        if value >= 8 && value <= 15 {
            state.highlighted = true
            updateColor(state: &state, negative: negative, color: value - 8)
        } else {
            state.highlighted = false
            updateColor(state: &state, negative: negative, color: value)
        }
    } else if elems[momelem].value  == val1 &&
              elems.count - momelem > 1 &&
              elems[momelem+1].value == val3 { // 38;2;<n> -> 24 Bit
        momelem += 2
        let r = elems[momelem].value
        momelem += 1
        let g = elems[momelem].value
        if elems.count - momelem > 0 {
            momelem += 1
        }
        let b = elems[momelem].value
        state.highlighted = false
        state.fc_colormode = .MODE_24BIT
        updateColor(state: &state, negative: negative, color:
            (r & 255) * 65536 + (g & 255) * 256 + (b & 255))
    } else {
        state.fc_colormode = .MODE_3BIT
        state.highlighted = false
        updateColor(state: &state, negative: negative, color: elems[momelem].value - colorOffset)
    }
}

func divide(_ dividend: Int, _ divisor: Int) -> Int {
    var result: div_t
    result = div(Int32(dividend), Int32(divisor))
    return Int(result.quot)
}

func make_rgb(_ color_id: Int) -> String {
    if color_id < 16 || color_id > 255 {
        return ""
    }
    if color_id >= 232 {
        let index = color_id - 232
        let grey = index * 256 / 24
        return String(format: "02x%02x%02x", grey, grey, grey)
    }
    let index_R = divide((color_id - 16), 36)
    var rgb_R: Int
    if index_R > 0 {
        rgb_R = 55 + index_R * 40
    } else {
        rgb_R = 0
    }

    let index_G = divide((color_id - 16) % 36, 6)
    var rgb_G: Int
    if index_G > 0 {
        rgb_G = 55 + index_G * 40
    } else {
        rgb_G = 0
    }

    let index_B = (color_id - 16) % 6
    var rgb_B: Int
    if index_B > 0 {
        rgb_B = 55 + index_B * 40
    } else {
        rgb_B = 0
    }
    return String(format: "%02x%02x%02x", rgb_R, rgb_G, rgb_B)
}

func ansiToHtml(ansi: String) -> String {
    let esc: Character = "\u{1B}"
    let input: [Character] = Array(ansi) // this gives us O(1) indexing performance
    var result = ""

    // Begin of Conversion
    var state = State()
    var oldstate: State
    var negative = false //No negative image
    var line = 0
    var newline = -1

    var offset = 0
    while offset < input.count {
        var c = input[offset]
        if c == esc {
            oldstate = state
            //Searching the end (a letter) and safe the insert:
            offset += 1; c = input[offset]
            if c == "[" { // CSI code, see https://en.wikipedia.org/wiki/ANSI_escape_code#Colors
                var buffer = "["
                while (c<"A") || ((c>"Z") && (c<"a")) || (c>"z") {
                    offset += 1; c = input[offset]
                    buffer.append(c)
                    if c == ">" { //end of htop
                        break
                    }
                }
                switch c {
                case "m":
                    let elems = parseInsert(buffer)
                    var momelem = 0
                    while momelem < elems.count {
                        switch elems[momelem].value {
                        case 0: // 0 - Reset all
                            state = State()
                            negative = false

                        case 1: // 1 - Enable Bold
                            state.bold = true

                        case 3: // 3 - Enable Italic
                            state.italic = true

                        case 4: // 4 - Enable underline
                            state.underline = true

                        case 5: // 5 - Slow Blink
                            state.blink = true

                        case 7: // 7 - Inverse video
                            swapColors(&state)
                            negative = !negative

                        case 9: // 9 - Enable Crossed-out
                            state.crossedout = true

                        case 21, // 21 - Reset bold;
                             22: // 22 - Not bold, not "high intensity" color
                            state.bold = false

                        case 23: // 23 - Reset italic
                            state.italic = false

                        case 25: // 24 - Reset underline
                            state.underline = false

                        case 27: // Reset inverted
                            if negative {
                                swapColors(&state)
                                negative = false
                            }

                        case 29: // Reset crossed-out
                            state.crossedout = false

                        case 30...39: // 3X - Set foreground color
                            updateColorState(momelem: &momelem, elems: elems, state: &state, negative: negative,
                                val1: 38, val2: 5, val3: 2, colorOffset: 30)

                        case 40...49: // 4X - Set background color
                            updateColorState(momelem: &momelem, elems: elems, state: &state, negative: negative,
                                 val1: 48, val2: 5, val3: 2, colorOffset: 40)

                        case 90...97: // 9X - Set foreground color highlighted
                            state.fc_colormode = .MODE_3BIT
                            state.highlighted = true
                            updateColor(state: &state, negative: negative, color: elems[momelem].value - 90)

                        case 100...107: // 10X Set background color hightlighted
                            state.fc_colormode = .MODE_3BIT
                            state.highlighted = true
                            updateColor(state: &state, negative: negative, color: elems[momelem].value - 100)

                        default:
                            continue
                        }
                        momelem += 1
                    }

                default:
                    print("Ansi2HtmlParse is skipping \(c)")
                }
                //Checking the differences
                if state != oldstate { //ANY Change
                    // If old state was different than the default one, close the current <span>
                    if oldstate != State() {
                        result.append("</span>")
                    }
                    // Open new <span> if current state differs from the default one
                    if state != State() {
                        result.append("<span class=\"")
                        if state.underline {
                            result.append("underline ")
                        }
                        if state.bold {
                           result.append("bold ")
                        }
                        if state.italic {
                           result.append("italic ")
                        }
                        if state.blink {
                           result.append("blink ")
                        }
                        if state.crossedout {
                           result.append("crossed-out ")
                        }
                        if state.highlighted {
                           result.append("highlighted ")
                        }
                        if state.fc_colormode != .MODE_3BIT &&
                           (state.fc_colormode != .MODE_8BIT || state.fc > 15) {
                            result.append("\" style=\"")
                        }
                        switch state.fc_colormode {
                        case .MODE_3BIT:
                            if state.fc >= 0 && state.fc <= 9 {
                                result.append(fcstyle[state.fc])
                            }
                        case .MODE_8BIT:
                            if state.fc >= 0 && state.fc <= 7 {
                                result.append(fcstyle[state.fc])
                            } else {
                                result.append("color:#\(make_rgb(state.fc))")
                            }
                        case .MODE_24BIT:
                            result.append(String(format: "color:#%06x;", state.fc))
                        }
                        result.append("\">")
                    }
                }
            }
        } else if c != "\u{B}" {
            line += 1
            if newline >= 0 {
                while newline > line {
                    result.append(" ")
                    line += 1
                }
                newline = -1
            }
            result.append(c)
        }
        offset += 1
    }

    // If current state is different than the default, there is a <span> open - close it
    if state != State() {
        result.append("</span>")
    }

    return result
}