//
//  PlainTextDocument.swift
//  Savitar2
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import Cocoa

/// Standalone plain-text editor (Savitar 1 text document parity: .txt, .text, .log).
class PlainTextDocument: NSDocument {
    static let fileType = "public.plain-text"
    fileprivate static let windowFrameAutosaveName = "PlainTextDocument"

    @discardableResult
    static func openNewUntitled() -> Bool {
        do {
            let document = try NSDocumentController.shared.makeUntitledDocument(ofType: fileType)
            NSDocumentController.shared.addDocument(document)
            document.makeWindowControllers()
            return true
        } catch {
            NSApp.presentError(error)
            return false
        }
    }

    static func document(matchingTitle title: String) -> PlainTextDocument? {
        let needle = title.lowercased()
        for document in NSDocumentController.shared.documents {
            guard let textDocument = document as? PlainTextDocument,
                  let window = document.windowControllers.first?.window else { continue }
            if window.title.lowercased().contains(needle) {
                return textDocument
            }
        }
        return nil
    }

    func appendText(_ text: String) {
        guard !text.isEmpty else { return }
        if let textView = textView {
            let endLocation = (textView.string as NSString).length
            textView.insertText(text, replacementRange: NSRange(location: endLocation, length: 0))
            textView.scrollRangeToVisible(NSRange(location: endLocation + (text as NSString).length, length: 0))
        } else {
            loadedContent += text
            updateChangeCount(.changeDone)
        }
    }

    private var textView: NSTextView?
    private var loadedContent = ""

    override class var autosavesInPlace: Bool {
        true
    }

    override init() {
        super.init()
        undoManager?.levelsOfUndo = 50
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func makeWindowControllers() {
        let scrollView = NSTextView.scrollableTextView()
        guard let textView = scrollView.documentView as? NSTextView else { return }

        textView.isRichText = false
        textView.isEditable = true
        textView.isSelectable = true
        textView.allowsUndo = true
        textView.font = NSFont.userFixedPitchFont(ofSize: NSFont.systemFontSize)
            ?? NSFont(name: "Monaco", size: 12)
        textView.string = loadedContent
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false

        self.textView = textView

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textDidChange(_:)),
            name: NSText.didChangeNotification,
            object: textView
        )

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 400),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = displayName
        window.minSize = NSSize(width: 320, height: 200)

        scrollView.frame = window.contentView!.bounds
        scrollView.autoresizingMask = [.width, .height]
        window.contentView?.addSubview(scrollView)

        let windowController = PlainTextWindowController(window: window, textView: textView)
        windowController.windowFrameAutosaveName = Self.windowFrameAutosaveName
        addWindowController(windowController)
        windowController.showWindow(self)
    }

    override func printDocument(_: Any?) {
        guard let textView = textView,
              let window = windowControllers.first?.window else { return }

        let printInfo = (NSPrintInfo.shared.copy() as? NSPrintInfo) ?? NSPrintInfo()
        let operation = NSPrintOperation(view: textView, printInfo: printInfo)
        operation.jobTitle = preferredFilenameBase
        operation.showsPrintPanel = true
        operation.showsProgressPanel = true
        operation.runModal(for: window, delegate: nil, didRun: nil, contextInfo: nil)
    }

    @objc private func textDidChange(_ notification: Notification) {
        guard notification.object as? NSTextView === textView else { return }
        updateChangeCount(.changeDone)
    }

    override func data(ofType _: String) throws -> Data {
        let text = textView?.string ?? loadedContent
        guard let data = text.data(using: .utf8) else {
            throw NSError(domain: "Savitar2", code: 4,
                          userInfo: [NSLocalizedDescriptionKey: "Failed to encode text as UTF-8"])
        }
        return data
    }

    override func read(from data: Data, ofType _: String) throws {
        if let string = String(data: data, encoding: .utf8) {
            loadedContent = string
        } else if let string = String(data: data, encoding: .macOSRoman) {
            loadedContent = string
        } else {
            throw NSError(domain: "Savitar2", code: 5,
                          userInfo: [NSLocalizedDescriptionKey: "Unrecognized text encoding"])
        }
        textView?.string = loadedContent
        syncWindowTitles()
    }

    override func save(to url: URL, ofType typeName: String,
                       for saveOperation: NSDocument.SaveOperationType,
                       completionHandler: @escaping (Error?) -> Void) {
        super.save(to: url, ofType: typeName, for: saveOperation) { error in
            if error == nil {
                self.syncWindowTitles()
            }
            completionHandler(error)
        }
    }

    private var preferredFilenameBase: String {
        if let url = fileURL {
            return url.deletingPathExtension().lastPathComponent
        }
        return displayName
    }

    private func syncWindowTitles() {
        let title = preferredFilenameBase
        for controller in windowControllers {
            controller.window?.title = title
        }
    }
}

private final class PlainTextWindowController: NSWindowController {
    private weak var textView: NSTextView?

    init(window: NSWindow, textView: NSTextView) {
        self.textView = textView
        super.init(window: window)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        guard let window = window else { return }

        let autosaveName = PlainTextDocument.windowFrameAutosaveName
        window.setFrameAutosaveName(autosaveName)
        if !window.setFrameUsingName(autosaveName) {
            window.center()
        }

        if let textView = textView {
            window.makeFirstResponder(textView)
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowDidBecomeKeyNotification(_:)),
            name: NSWindow.didBecomeKeyNotification,
            object: window
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func windowDidBecomeKeyNotification(_ notification: Notification) {
        guard notification.object as? NSWindow === window else { return }
        guard let textView = textView, let window = window else { return }
        if window.firstResponder !== textView {
            window.makeFirstResponder(textView)
        }
    }
}
