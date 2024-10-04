//
//  NoteCategory.swift
//  VoiceNote
//
//  Created by Pavel Kuznetsov on 04.10.2024.
//

enum NoteCategory: String, CaseIterable, Identifiable {
    case education
    case work
    case notes
    
    var id: Self { self }
}
