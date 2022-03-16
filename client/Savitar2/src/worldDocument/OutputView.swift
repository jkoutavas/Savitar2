//
//  OutputView.swift
//  Savitar2
//
//  Created by Jay Koutavas on 11/28/19.
//  Copyright © 2019 Heynow Software. All rights reserved.
//

import WebKit

class OutputView: WKWebView {
    var ansiToHtml = Ansi2HtmlParser()
    var useANSI = true
    var useHTML = false

    private var loggingFileHandle: FileHandle?

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
        window.scrollTo({ left: 0, top: document.body.scrollHeight, behavior: "smooth" });
        """
        run(javaScript: js)
    }

    func output(string: String,
                makeAppend: Bool = false,
                appending: Bool = false,
                appendID: Int = 0,
                attributes _: [NSAttributedString.Key: Any]? = nil) {
        // Clean-up incoming string by replacing carriage returns and linefeeds with HTML <br> elements
        var cleanString = string
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
            plainText = ansiToHtml.parse(ansi: string, hideANSI: true)
            if let text = plainText, let data = text.data(using: String.Encoding.utf8) {
                fh.write(data)
            }
        }

        if AppContext.hasContinuousSpeech(), AppContext.shared.prefs.continuousSpeechEnabled {
            if plainText == nil {
                plainText = ansiToHtml.parse(ansi: string, hideANSI: true)
            }
            if let text = plainText {
                AppContext.shared.speakerMan.speak(text: text,
                                                   voiceName: AppContext.shared.prefs.continuousSpeechVoice)
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
            window.scrollTo({ left: 0, top: document.body.scrollHeight, behavior: "smooth" });
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
            window.scrollTo({ left: 0, top: document.body.scrollHeight, behavior: "smooth" });
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

    func setStyle(world: World) {
        useANSI = world.flags.contains(.ansi)
        useHTML = world.flags.contains(.html)

        let backColor = world.backColor.toHex!
        let foreColor = world.foreColor.toHex!
        let linkColor = world.linkColor.toHex!

        let black = contrast(color: NSColor.black, withHex: backColor)
        let red = contrast(color: NSColor.red, withHex: backColor)
        let green = contrast(color: NSColor.green, withHex: backColor)
        let yellow = contrast(color: NSColor.yellow, withHex: backColor)
        let blue = contrast(color: NSColor.blue, withHex: backColor)
        let magenta = contrast(color: NSColor.magenta, withHex: backColor)
        let cyan = contrast(color: NSColor.cyan, withHex: backColor)
        let white = contrast(color: NSColor.white, withHex: backColor)

        let bgblack = contrast(color: NSColor.black, withHex: foreColor)
        let bgred = contrast(color: NSColor.red, withHex: foreColor)
        let bggreen = contrast(color: NSColor.green, withHex: foreColor)
        let bgyellow = contrast(color: NSColor.yellow, withHex: foreColor)
        let bgblue = contrast(color: NSColor.blue, withHex: foreColor)
        let bgmagenta = contrast(color: NSColor.magenta, withHex: foreColor)
        let bgcyan = contrast(color: NSColor.cyan, withHex: foreColor)
        let bgwhite = contrast(color: NSColor.white, withHex: foreColor)

        let ss = """
        <style id='head-style'>
        body { background-color: #\(backColor); }
        body * {font: \(world.fontSize)px \(world.fontName)}
        code {font: \(world.monoFontSize)px \(world.monoFontName);}
        a { color: #\(linkColor); }
        pre {
            overflow-x: auto;
            white-space: pre-wrap;
            white-space: -moz-pre-wrap;
            white-space: -pre-wrap;
            white-space: -o-pre-wrap;
            word-wrap: break-word;
            display: inline;
            margin: 0;
        }
        .reset       {color: #\(foreColor);}
        .bg-reset    {background-color: #\(backColor);}
        .inverted    {color: #\(backColor);}
        .bg-inverted {background-color: #\(foreColor);}
        .black       {color: #\(black);}
        .red         {color: #\(red);}
        .green       {color: #\(green);}
        .yellow      {color: #\(yellow);}
        .blue        {color: #\(blue);}
        .magenta     {color: #\(magenta);}
        .cyan        {color: #\(cyan);}
        .white       {color: #\(white);}
        .bg-black    {background-color: #\(bgblack);}
        .bg-red      {background-color: #\(bgred);}
        .bg-green    {background-color: #\(bggreen);}
        .bg-yellow   {background-color: #\(bgyellow);}
        .bg-blue     {background-color: #\(bgblue);}
        .bg-magenta  {background-color: #\(bgmagenta);}
        .bg-cyan     {background-color: #\(bgcyan);}
        .bg-white    {background-color: #\(bgwhite);}
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
}
