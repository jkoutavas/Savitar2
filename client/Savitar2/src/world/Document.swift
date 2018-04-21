//
//  Document.swift
//  Savitar2
//
//  Created by Jay Koutavas on 11/21/17.
//  Copyright © 2017-2018 Heynow Software. All rights reserved.
//

import Cocoa

class Document: NSDocument, OutputProtocol {
    let world = World()
    
    var endpoint: Endpoint?
    var splitViewController : SplitViewController?
    
    override func close() {
        super.close()
        endpoint?.close()
    }

    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        guard let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as? WindowController else { return }
        
        self.addWindowController(windowController)
        windowController.world = world
        
        splitViewController = windowController.contentViewController as? SplitViewController
        guard let svc = splitViewController else { return }
        
        guard let window = windowController.window else { return }
        window.makeFirstResponder(svc.inputViewController.textView)

        svc.inputViewController.foreColor = world.foreColor
        svc.inputViewController.backColor = world.backColor
        svc.outputViewController.foreColor = world.foreColor
        svc.outputViewController.backColor = world.backColor
        
        if let font = NSFont(name: world.fontName, size: world.fontSize) {
            svc.inputViewController.font = font
            svc.outputViewController.font = font
        }
        
        if world.version == 1 {
            window.setContentSize(world.windowSize)
            if let titleHeight = (windowController.window?.titlebarHeight) {
                if let screenSize = NSScreen.main?.frame.size {
                    window.setFrameTopLeftPoint(NSMakePoint(world.position.x, screenSize.height - world.position.y + titleHeight))
                }
            }
            
            let dividerHeight: CGFloat = svc.splitView.dividerThickness
            let rowHeight = svc.inputViewController.rowHeight
            let split: CGFloat = world.windowSize.height - dividerHeight - rowHeight * CGFloat(world.inputRows+1)
            svc.splitView.setPosition(split, ofDividerAt: 0)
            
            window.setIsZoomed(world.zoomed)
        }
        
        windowController.windowFrameAutosaveName = NSWindow.FrameAutosaveName(rawValue: world.GUID)
        splitViewController?.splitView.autosaveName = NSSplitView.AutosaveName(rawValue: world.GUID)
        
        output(result:.success("Welcome to Savitar 2.0!\n\n"))
        endpoint = Endpoint(port:world.port, host:world.host, outputter:self)
        svc.inputViewController.endpoint = endpoint
        endpoint?.connectAndRun()
    }

    override func read(from data: Data, ofType typeName: String) throws {
        try world.read(from: data)
    }

    func output(result : OutputResult) {
        func output(string: String, attributes: [NSAttributedStringKey : Any]? = nil) {
            let outputView = self.splitViewController?.outputViewController.textView
        
            outputView?.textStorage?.append(NSAttributedString(string: string, attributes: attributes))
            outputView?.scrollToEndOfDocument(nil)
        }
        
        var attributes = [NSAttributedStringKey: AnyObject]()
        attributes[NSAttributedStringKey.font] = NSFont(name: world.fontName, size: world.fontSize)
        switch result {
            case .success(let message):
                attributes[NSAttributedStringKey.foregroundColor] = world.foreColor
                output(string: message, attributes: attributes)
            case .error(let error):
                attributes[NSAttributedStringKey.foregroundColor] = NSColor.red
                output(string: error, attributes: attributes)
        }
    }
    
    override func data(ofType typeName: String) throws -> Data {
        world.version = 2
        return try world.data()
    }
}
