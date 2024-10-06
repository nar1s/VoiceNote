//
//  NoteCategory.swift
//  VoiceNote
//
//  Created by Pavel Kuznetsov on 04.10.2024.
//

enum NoteCategory: String, CaseIterable {
    case education
    case work
    case notes
}

extension NoteCategory: Identifiable {
    var id: Self { self }
}
