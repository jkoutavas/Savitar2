//
//  WebViewFunctions.swift
//  Savitar2
//
//  Created by Jay Koutavas on 11/28/19.
//  Copyright © 2019 Heynow Software. All rights reserved.
//

import Foundation
import WebKit

extension WKWebView {
    func output(string: String, attributes: [NSAttributedString.Key: Any]? = nil) {
        // Clean-up incoming string by replacing carriage returns and linefeeds with HTML <br> elements
        let cleanString = string
            .replacingOccurrences(of: "\r\n", with: "<br>")
            .replacingOccurrences(of: "\n", with: "<br>")
            .replacingOccurrences(of: "\\", with: "\\\\")

        // Convert any ANSI escape codes to HTML spans
        var resultCStrQ: UnsafeMutablePointer<CChar>?
        let unsafeInput = UnsafeMutablePointer<CChar>(mutating: cleanString)
        ahamain(0, nil, unsafeInput, &resultCStrQ)
        if let resultCStr = resultCStrQ {
            let result = String(cString: resultCStr)
            let htmlStr = result.replacingOccurrences(of: "\"", with: "'")
            // Now append this output as a new <div>
            let js = """
                var i=document.createElement('div');
                i.setAttribute('class', 'reset bg-reset');
                i.innerHTML=\"<pre>\(htmlStr)</pre>\";document.body.appendChild(i);
            """
            run(javaScript: js)

            printDOM(element: "document.body.innerHTML")
        }
    }

    func setStyle(world: World) {
        let backColor = world.backColor.toHex ?? "black"
        let foreColor = world.foreColor.toHex ?? "white"
        let linkColor = world.linkColor.toHex ?? "blue"

         let ss = """
         <style type="text/css">
             body {font-family: '\(world.fontName)'; background-color: #\(backColor); font-size: \(world.fontSize)px;}
             a { color: #\(linkColor); }
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

         run(javaScript: "document.head.insertAdjacentHTML('beforeend', `\(ss)`)") // TODO: do a replace of the style

         printDOM(element: "document.head.innerHTML")
    }

    func run(javaScript: String) {
        evaluateJavaScript("(function() {\(javaScript); })();") { (result, error) in
            if error != nil {
                print(error!)
            }
         }
    }

    // Debug function, dump current html to the console
    func printDOM(element: String) {
        evaluateJavaScript(element) { (result, error) in
            if error != nil {
                print(error!)
            }
        }
    }
}
