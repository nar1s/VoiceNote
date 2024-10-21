//
//  SharedFile.swift
//  VoiceNote
//
//  Created by Pavel Kuznetsov on 19.10.2024.
//


import SwiftUI
import UniformTypeIdentifiers

struct SharedFile: Transferable {
    let fileURL: URL
    
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: .utf8PlainText) { sharedFile in
            SentTransferredFile(sharedFile.fileURL)
        }
        FileRepresentation(exportedContentType: .pdf) { sharedFile in
            SentTransferredFile(sharedFile.fileURL)
        }
    }
}
