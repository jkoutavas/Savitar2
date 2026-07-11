//
//  SessionFileUpload.swift
//  Savitar2
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import Foundation

enum SessionFileUpload {
    enum UploadError: Equatable, Swift.Error {
        case notConnected
        case emptyPath
        case notAFile(path: String)
        case fileNotFound(path: String)
        case unreadable(path: String)
    }

    static func resolvePath(_ path: String) -> String {
        let trimmed = path.trimmingCharacters(in: .whitespacesAndNewlines)
        let expanded = (trimmed as NSString).expandingTildeInPath
        if expanded.hasPrefix("/") {
            return expanded
        }
        return FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(expanded)
            .path
    }

    @discardableResult
    static func upload(path: String, session: Session) -> Swift.Result<Int, UploadError> {
        upload(path: path, session: session, send: { session.sendData(data: $0) })
    }

    @discardableResult
    static func upload(path: String,
                       session: Session,
                       send: (Data) -> Void) -> Swift.Result<Int, UploadError> {
        guard session.status == .ConnectComplete else { return .failure(.notConnected) }

        let trimmed = path.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .failure(.emptyPath) }

        let resolved = resolvePath(trimmed)
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: resolved, isDirectory: &isDirectory) else {
            return .failure(.fileNotFound(path: resolved))
        }
        guard !isDirectory.boolValue else {
            return .failure(.notAFile(path: resolved))
        }

        let url = URL(fileURLWithPath: resolved)
        guard let data = try? Data(contentsOf: url) else {
            return .failure(.unreadable(path: resolved))
        }

        send(data)
        return .success(data.count)
    }
}
