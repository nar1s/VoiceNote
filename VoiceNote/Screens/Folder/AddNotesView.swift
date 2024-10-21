//
//  AddNotesView.swift
//  VoiceNote
//
//  Created by Pavel Kuznetsov on 16.10.2024.
//


import SwiftUI

struct AddNotesView: View {
    // MARK: Public properties
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var notesManager: NotesManager
    var folder: Folder
    
    // MARK: Private properties
    @State private var folderTitle: String = ""
    @FetchRequest(sortDescriptors: [SortDescriptor(\.created, order: .forward)])
    var notes: FetchedResults<Note>
    
    @State private var selectedNotes: [Note] = []
    @State private var availableNotes: [Note] = []
    
    // MARK: View body
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Выбор заметок для папки")
                    .font(.title3)
                if !availableNotes.isEmpty {
                    LazyVStack(spacing: 10) {
                        ForEach(availableNotes, id: \.self) { note in
                            HStack {
                                Text(note.name ?? "")
                                Spacer()
                                Image(systemName: selectedNotes.contains(note) ? "minus.square": "plus.app")
                                    .onTapGesture {
                                        withAnimation {
                                            addOrRemoveNote(note)
                                        }
                                    }
                            }
                            .padding()
                            .background(selectedNotes.contains(note) ? .blue : .gray)
                            .clipShape(.rect(cornerRadius: 20))
                        }
                    }
                } else {
                    Text("Все заметки уже в папке!")
                }
            }
        }
        .padding()
        .onAppear {
            let allNotesSet = Set(notes)
            guard let folderNotes = folder.note as? Set<Note> else { return }
            let uniqueNotes = allNotesSet.symmetricDifference(folderNotes)
            availableNotes = Array(uniqueNotes)
        }
        .safeAreaInset(edge: .top) {
            Text("Выбор заметок для папки")
                .font(.title)
        }
        .safeAreaInset(edge: .bottom) {
            Button("Сохранить") {
                addNotesToFolder()
                dismiss()
            }
            .foregroundStyle(.white)
            .padding()
            .background(.gray)
            .clipShape(.rect(cornerRadius: 20))
        }
        
    }
    // MARK: Private methods
    private func addNotesToFolder() {
        selectedNotes.forEach { note in
            folder.addToNote(note)
        }
        notesManager.save()
    }
    
    private func addOrRemoveNote(_ note: Note) {
        if let index = selectedNotes.firstIndex(where: {$0 == note}) {
            selectedNotes.remove(at: index)
        } else {
            selectedNotes.append(note)
        }
    }
}

#Preview {
    let folder = Folder.mockObject(context: PersistentConfigurator.preview.mainContext)
    AddNotesView(folder: folder)
        .environmentObject(NotesManager.preview)
        .environment(
            \.managedObjectContext,
             PersistentConfigurator.preview.mainContext
        )
}
