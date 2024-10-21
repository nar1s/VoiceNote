//
//  FolderView.swift
//  VoiceNote
//
//  Created by Pavel Kuznetsov on 15.10.2024.
//

import SwiftUI

struct FolderView: View {
    // MARK: - Environment
    @EnvironmentObject var notesManager: NotesManager
    // MARK: - Public properties
    var folder: Folder

    @FetchRequest var folderNotes: FetchedResults<Note>

    init(folder: Folder) {
        self.folder = folder
        _folderNotes = FetchRequest<Note>(
            sortDescriptors: [NSSortDescriptor(keyPath: \Note.created, ascending: true)],
            predicate: NSPredicate(format: "ANY folder == %@", folder)
        )
    }

    // MARK: - Private properties
    @State var needToShowAddNoteView = false
    var body: some View {
        List {
            Section(header: Text("ЗАМЕТКИ В ПАПКЕ")) {
                if folderNotes.count != 0 {
                    ForEach(folderNotes, id: \.self) { note in
                        NavigationLink(value: note) {
                            Text(note.name ?? "")
                        }
                    }
                    .onDelete { indexSet in
                        deleteNote(at: indexSet)
                    }
                } else {
                    Text("В данной папке пока нет заметок")
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Image(systemName: "note.text.badge.plus")
                    .onTapGesture {
                        needToShowAddNoteView = true
                    }
            }
        }
        .sheet(isPresented: $needToShowAddNoteView) {
            AddNotesView(folder: folder)
        }
        .navigationTitle(folder.folderName ?? "")
    }
    
    private func deleteNote(at indexSet: IndexSet) {
        let notesToDelete = indexSet.map { folderNotes[$0] }
        notesManager.deleteNote(notesToDelete)
    }
}

#Preview {
    let folder = Folder.mockObject(context: PersistentConfigurator.preview.mainContext)
    FolderView(folder: folder)
        .environment(
            \.managedObjectContext,
             PersistentConfigurator.preview.mainContext
        )
}
