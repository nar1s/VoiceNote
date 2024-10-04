//
//  MainView.swift
//  VoiceNote
//
//  Created by Pavel Kuznetsov on 02.10.2024.
//


import SwiftUI

struct MainView: View {
    @State private var searchText = ""
    @State var noteModels = NoteModel.mockedData
    @State var stackPath = NavigationPath()
    var body: some View {
        NavigationStack(path: $stackPath) {
            List {
                Section(header: Text("ВСЕ ЗАМЕТКИ")) {
                    ForEach(noteModels) { model in
                        NavigationLink(value: model.id) {
                            Text(model.name)
                        }
                    }
                }
            }
            .navigationTitle("Заметки")
            .navigationDestination(for: UUID.self) { modelID in
                if let modelIndex = noteModels.firstIndex(where: { $0.id == modelID }) {
                    NoteView(noteModel: $noteModels[modelIndex])
                }
            }
        }
        .searchable(text: $searchText, prompt: "Введите название заметки, категории")
        .overlay(alignment: .bottom) {
            HStack {
                Spacer()
                Circle()
                    .foregroundStyle(.red)
                    .frame(width: 60, height: 60)
                    .padding(.top)
                Spacer()
            }
            .background(.ultraThinMaterial)
        }
    }
}

#Preview {
    MainView()
}
