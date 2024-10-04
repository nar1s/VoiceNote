//
//  NoteView.swift
//  VoiceNote
//
//  Created by Pavel Kuznetsov on 04.10.2024.
//


import SwiftUI

struct NoteView: View {
    // MARK: Public properties
    @Binding var noteModel: NoteModel
    // MARK: Private properties
    @State private var isPlaying: Bool = false
    // MARK: View body
    var body: some View {
        Form {
            Section {
                TextField("Введите название", text: $noteModel.name)
            } header: {
                Text("НАЗВАНИЕ")
            }
            Section {
                HStack(spacing: 20) {
                    Toggle(isOn: $isPlaying) {
                        Image(systemName: isPlaying ? "pause.circle" : "play.circle")
                            .resizable()
                            .frame(width: 40, height: 40)
                    }
                    .toggleStyle(.button)
                    Image(systemName: "waveform")
                        .resizable()
                }
            } header: {
                Text("АУДИОФАЙЛ")
            }
            Section {
                Picker("NoteCategory", selection: $noteModel.categoty) {
                    ForEach(NoteCategory.allCases) { category in
                        Text(category.rawValue)
                    }
                }
            } header: {
                Text("КАТЕГОРИЯ")
            }
            Section {
                List(noteModel.highligts, id: \.self) { highlight in
                    HStack {
                        Text(highlight.title + ":")
                        Spacer()
                        HStack {
                            Text(highlight.startTs.formatted() + " c")
                            Image(systemName: "arrowshape.right")
                            Text(highlight.endTs.formatted() + " c")
                        }
                    }
                }
            } header: {
                Text("ВРЕМЕННЫЕ МЕТКИ")
            }
            Section {
                Text(noteModel.text)
            } header: {
                Text("ТЕКСТ ЗАМЕТКИ")
            }
        }
    }
}

#Preview {
    NoteView(noteModel: .constant(NoteModel.mockObject))
}
