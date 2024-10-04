//
//  NoteHighlightsModel.swift
//  VoiceNote
//
//  Created by Pavel Kuznetsov on 04.10.2024.
//

import Foundation

struct NoteHighlightsModel: Hashable {
    let title: String
    let startTs: TimeInterval
    let endTs: TimeInterval
}
