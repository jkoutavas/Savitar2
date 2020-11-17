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
                attributes: [NSAttributedString.Key: Any]? = nil) {
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
        let result = ansiToHtml.parse(ansi: cleanString)
        if result.count > 0 {
            let htmlStr = result.replacingOccurrences(of: "\"", with: "'")
            output(html: htmlStr, makeAppend: makeAppend, appending: appending, appendID: appendID)
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

    func setStyle(world: World) {
        let backColor = world.backColor.toHex ?? "black"
        let foreColor = world.foreColor.toHex ?? "white"
        let linkColor = world.linkColor.toHex ?? "blue"
        useANSI = world.flags.contains(.ansi)
        useHTML = world.flags.contains(.html)

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
        .dimgray     {color: dimgray;}
        .red         {color: red;}
        .green       {color: green;}
        .yellow      {color: olive;}
        .blue        {color: blue;}
        .purple      {color: purple;}
        .cyan        {color: teal;}
        .white       {color: gray;}
        .bg-black    {background-color: black;}
        .bg-red      {background-color: red;}
        .bg-green    {background-color: green;}
        .bg-yellow   {background-color: olive;}
        .bg-blue     {background-color: blue;}
        .bg-purple   {background-color: purple;}
        .bg-cyan     {background-color: teal;}
        .bg-white    {background-color: gray;}
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

    func run(javaScript: String) {
        evaluateJavaScript("(function() {\(javaScript); })();") { (result, error) in
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
        evaluateJavaScript(element) { (result, error) in
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
