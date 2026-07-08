//
//  OutputView.swift
//  Savitar2
//
//  Created by Jay Koutavas on 11/28/19.
//  Copyright © 2019 Heynow Software. All rights reserved.
//

import Cocoa
import WebKit

class OutputView: WKWebView {
    var ansiToHtml = Ansi2HtmlParser()
    var useANSI = true
    var useHTML = false
    private(set) var isScrollLocked = false

    private var loggingFileHandle: FileHandle?
    private(set) var layoutFontName = "Monaco"
    private(set) var layoutFontSize: CGFloat = 9
    private(set) var wordWrapEnabled = false

    override var acceptsFirstResponder: Bool { true }

    override func mouseDown(with event: NSEvent) {
        window?.makeFirstResponder(self)
        super.mouseDown(with: event)
    }

    func find(string: String, forward: Bool) {
        guard !string.isEmpty else { return }
        let pasteboard = NSPasteboard(name: .find)
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(string, forType: .string)

        let escaped = string
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "'", with: "\\'")
            .replacingOccurrences(of: "\r", with: "")
            .replacingOccurrences(of: "\n", with: "\\n")
        let backwards = forward ? "false" : "true"
        run(javaScript: "window.find('\(escaped)', false, \(backwards), true, false, true, false);")
    }

    func setScrollLocked(_ locked: Bool) {
        isScrollLocked = locked
    }

    @discardableResult
    func toggleScrollLock() -> Bool {
        isScrollLocked.toggle()
        return isScrollLocked
    }

    func scrollToBottomJavaScript() -> String {
        guard !isScrollLocked else { return "" }
        return """
        window.scrollTo({ left: 0, top: document.body.scrollHeight, behavior: "smooth" });
        """
    }

    override func willOpenMenu(_ menu: NSMenu, with _: NSEvent) {
        menu.removeAllItems()
        let menuItem = NSMenuItem()
        menuItem.title = "Clear"
        menuItem.action = #selector(clearAction)
        menuItem.target = self
        menu.addItem(menuItem)
    }

    @objc func clearAction(_: AnyObject) {
        clear()
    }

    func clear() {
        let js = """
        document.body.innerHTML = ''
        \(scrollToBottomJavaScript())
        """
        run(javaScript: js)
    }

    func selectedPlainText(completion: @escaping (String?) -> Void) {
        evaluateJavaScript("window.getSelection().toString()") { result, _ in
            let text = (result as? String)?
                .trimmingCharacters(in: .whitespacesAndNewlines)
            completion(text?.isEmpty == false ? text : nil)
        }
    }

    func output(string: String,
                makeAppend: Bool = false,
                appending: Bool = false,
                appendID: Int = 0,
                attributes _: [NSAttributedString.Key: Any]? = nil) {
        let mutedBell = AppContext.shared.prefs.flags.contains(.muteBell)
        let displayString = TerminalBell.process(string, muted: mutedBell)

        // Clean-up incoming string by replacing carriage returns and linefeeds with HTML <br> elements
        var cleanString = displayString
        if !useHTML {
            cleanString = cleanString
                .replacingOccurrences(of: "<", with: "&lt;")
                .replacingOccurrences(of: ">", with: "&gt;")
        }
        cleanString = cleanString
            .replacingOccurrences(of: "\r\n", with: "<br>")
            .replacingOccurrences(of: "\n", with: "<br>")
            .replacingOccurrences(of: "\r", with: "")
            .replacingOccurrences(of: "\\", with: "\\\\")

        // Convert any ANSI escape codes to HTML spans
        let result = ansiToHtml.parse(ansi: cleanString, hideANSI: !useANSI)
        if result.count > 0 {
            let htmlStr = result.replacingOccurrences(of: "\"", with: "'")
            output(html: htmlStr, makeAppend: makeAppend, appending: appending, appendID: appendID)
        }

        var plainText: String?
        if let fh = loggingFileHandle {
            plainText = ansiToHtml.parse(ansi: displayString, hideANSI: true)
            if let text = plainText, let data = text.data(using: String.Encoding.utf8) {
                fh.write(data)
            }
        }

        if AppContext.hasContinuousSpeech(),
           AppContext.shared.prefs.continuousSpeechEnabled,
           !AppContext.shared.prefs.flags.contains(.muteSpeaking) {
            if plainText == nil {
                plainText = ansiToHtml.parse(ansi: displayString, hideANSI: true)
            }
            if let text = plainText {
                let voice = AppContext.shared.speakerMan.resolvedContinuousSpeechVoiceName()
                AppContext.shared.speakerMan.speak(text: text, voiceName: voice)
            }
        }
    }

    private func output(html: String, makeAppend: Bool, appending: Bool, appendID: Int) {
        if appending {
            // append this output to an existing <pre id={appendID}>
            let js = """
            //webkit.messageHandlers.logging.postMessage("appending text \(html) at \(appendID)");
            var elem = document.getElementById(\(appendID));
            if (elem !== null && elem.innerHTML !== null) {
                elem.innerHTML = elem.innerHTML + \"\(html)\";
            } else {
                webkit.messageHandlers.logging.postMessage("failed to append text \(html) at \(appendID)");
            }
            \(scrollToBottomJavaScript())
            """
            run(javaScript: js)
        } else {
            // append this output as a new <div> element
            let pre = makeAppend ? "<pre id=\(appendID)>" : "<pre>"
            let js = """
            //webkit.messageHandlers.logging.postMessage("making \(pre)");
            var i=document.createElement('div');
            i.setAttribute('class', 'reset bg-reset');
            i.innerHTML=\"\(pre)\(html)</pre>\";
            document.body.appendChild(i);
            \(scrollToBottomJavaScript())
            """
            run(javaScript: js)
        }
    }

    private func contrast(color: NSColor, withHex: String) -> String {
        var colorHex = color.toHex()!
        if colorHex == withHex {
            colorHex = color.darker(darker: 0.4).toHex()!
        }
        return colorHex
    }

    func setWordWrap(_ enabled: Bool) {
        wordWrapEnabled = enabled
    }

    func setStyle(world: World) {
        useANSI = world.flags.contains(.ansi)
        useHTML = world.flags.contains(.html)
        layoutFontName = world.monoFontName
        layoutFontSize = world.monoFontSize

        let backColor = world.backColor.toHex!
        let foreColor = world.foreColor.toHex!
        let linkColor = world.linkColor.toHex!

        let colorMan = AppContext.shared.prefs.colorMan
        colorMan.installDefaultsIfNeeded()

        func fgHex(_ hue: AnsiColorName, _ shade: AnsiColorShade) -> String {
            let name = AnsiPalette.name(for: hue, shade: shade)
            return contrast(color: colorMan.color(named: name), withHex: backColor)
        }

        // Foreground ANSI classes sourced from the user's palette. Dim (SGR 2 -> .lighter) and
        // intense (SGR 1 / bright -> .bold / .highlighted) variants override the base hue via CSS
        // specificity, so the ANSI parser needs no changes.
        let fgColorCSS = AnsiColorName.allCases.map { hue -> String in
            let name = hue.rawValue
            return """
            .\(name) {color: #\(fgHex(hue, .normal));}
            .lighter.\(name) {color: #\(fgHex(hue, .dim));}
            .bold.\(name), .highlighted.\(name) {color: #\(fgHex(hue, .intense));}
            """
        }.joined(separator: "\n")

        let bgColorCSS = AnsiColorName.allCases.map { hue -> String in
            let name = AnsiPalette.name(for: hue, shade: .normal)
            let hex = contrast(color: colorMan.color(named: name), withHex: foreColor)
            return ".bg-\(hue.rawValue) {background-color: #\(hex);}"
        }.joined(separator: "\n")

        let ss = """
        <style id='head-style'>
        body { background-color: #\(backColor); }
        body * {font: \(world.fontSize)px \(world.fontName)}
        code {font: \(world.monoFontSize)px \(world.monoFontName);}
        a { color: #\(linkColor); }
        \(WordWrapFormatting.outputPreCSS(wordWrapEnabled: wordWrapEnabled))
        .reset       {color: #\(foreColor);}
        .bg-reset    {background-color: #\(backColor);}
        .inverted    {color: #\(backColor);}
        .bg-inverted {background-color: #\(foreColor);}
        \(fgColorCSS)
        \(bgColorCSS)
        .underline   {text-decoration: underline;}
        .bold        {font-weight: bold;}
        .lighter     {font-weight: lighter;}
        .italic      {font-style: italic;}
        .blink       {animation: blink 2s ease infinite;}
        @keyframes blink{
            0%{opacity:0;}
            50%{opacity:1;}
            100%{opacity:0;}
        }
        .crossed-out {text-decoration: line-through;}
        .highlighted {filter: contrast(70%) brightness(190%);}

        ::-webkit-scrollbar {
            -webkit-appearance: none;
            width: 16px;
        }
        ::-webkit-scrollbar-thumb {
            border-radius: 4px;
            background-color: rgba(255,255,255,1);
            box-shadow: 0 0 1px rgba(0,0,0,.5);
        }

        </style>
        """

        // update the head <style> element
        run(javaScript: """
        var ss = document.getElementById('head-style');
        if (ss !== null) {
        ss.remove();
        }
        document.head.insertAdjacentHTML('beforeend', `\(ss)`)
        """)

        #if DEBUG_WKWEBKIT
//        printDOM(element: "document.head.innerHTML")
        #endif
    }

    func setLogging(world: World) {
        if loggingFileHandle != nil {
            loggingFileHandle!.closeFile()
            loggingFileHandle = nil
        }
        if world.logfilePath.count > 0 && world.loggingEnabled.boolValue {
            let url = URL(fileURLWithPath: world.logfilePath)
            if FileManager.default.fileExists(atPath: url.path) {
                if let fh = try? FileHandle(forWritingTo: url) {
                    if world.loggingType == .append {
                        fh.seekToEndOfFile()
                        loggingFileHandle = fh
                    } else {
                        fh.truncateFile(atOffset: 0)
                        fh.closeFile()
                        loggingFileHandle = try? FileHandle(forWritingTo: url)
                    }
                }
            }
        }
    }

    func run(javaScript: String) {
        evaluateJavaScript("(function() {\(javaScript); })();") { result, error in
            if error != nil {
                print("javascript run error: \(error!)")
            } else if result != nil {
                #if DEBUG_WKWEBKIT
                    print(result!)
                #endif
            }
        }
    }

    // Debug function, dump current html to the console
    func printDOM(element: String) {
        evaluateJavaScript(element) { result, error in
            if error != nil {
                print("javascript print error: \(error!)")
            } else if result != nil {
                print(result!)
            }
        }
    }

    func printSource() {
        evaluateJavaScript("document.documentElement.outerHTML.toString()",
                           completionHandler: { (html: Any?, _: Error?) in
                               print(html!)
                           })
    }

    func extractPlainText(completion: @escaping (String) -> Void) {
        evaluateJavaScript("document.body.innerText || '';") { result, _ in
            completion((result as? String) ?? "")
        }
    }
}
