//
//  NoteModel.swift
//  VoiceNote
//
//  Created by Pavel Kuznetsov on 04.10.2024.
//


import Foundation

struct NoteModel: Hashable, Identifiable {
    let id = UUID()
    var name: String
    let text: AttributedString
    var categoty: NoteCategory
    let audioFilePath: URL?
    let highligts: [NoteHighlightsModel]
}

// MARK: Data mock
extension NoteModel {
    static let mockedData: [NoteModel] = [
        .init(name: "Заметка 1", text: .init("Текст заметки 1"), categoty: .education, audioFilePath: nil, highligts: []),
        .init(name: "Заметка 2", text: .init("Текст заметки 2"), categoty: .education, audioFilePath: nil, highligts: []),
        .init(name: "Заметка 3", text: .init("Текст заметки 4"), categoty: .education, audioFilePath: nil, highligts: []),
        .init(name: "Заметка 4", text: .init("Текст заметки 5"), categoty: .education, audioFilePath: nil, highligts: []),
        .init(name: "Заметка 5", text: .init("Текст заметки 5"), categoty: .education, audioFilePath: nil, highligts: []),
    ]
    
    static let mockObject = NoteModel(
        name: "Заметка 5",
        text: .init("Текст заметки 5. \nДля примера"),
        categoty: .education,
        audioFilePath: nil,
        highligts: [
            .init(title: "Вступление", startTs: 10, endTs: 120),
            .init(title: "Важные моменты", startTs: 200, endTs: 560),
            .init(title: "Заключение", startTs: 700, endTs: 800)
        ]
    )
}
