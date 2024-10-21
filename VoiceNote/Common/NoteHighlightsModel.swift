//
//  NoteHighlightsModel.swift
//  VoiceNote
//
//  Created by Pavel Kuznetsov on 04.10.2024.
//

import Foundation

struct NoteHighlightsModel: Hashable, Codable {
    var title: String
    var startTs: TimeComponents
    var endTs: TimeComponents
}

struct TimeComponents: Hashable, Codable {
    var hours: Int = 0
    var minutes: Int = 0
    var seconds: Int = 0
    
    var totalTime: String {
        "\(hours):\(minutes):\(seconds)"
    }
    
    var isEmpty: Bool {
        (hours + minutes + seconds) == 0
    }
}
