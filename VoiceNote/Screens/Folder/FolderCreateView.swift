//
//  FolderCreateView.swift
//  VoiceNote
//
//  Created by Pavel Kuznetsov on 15.10.2024.
//


import SwiftUI

struct FolderCreateView: View {
    // MARK: Public properties
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var notesManager: NotesManager
    
    // MARK: Private properties
    @State private var folderTitle: String = ""
    @FetchRequest(sortDescriptors: [SortDescriptor(\.created, order: .forward)])
    var notes: FetchedResults<Note>
    
    @State private var selectedNotes: [Note] = []
    
    // MARK: View body
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Название папки")
                    .font(.title3)
                TextField("Название папки", text: $folderTitle)
                Text("Создание папки")
                    .font(.title3)
                LazyVStack(spacing: 10) {
                    ForEach(notes, id: \.self) { note in
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
            }
        }
        .padding()
        .safeAreaInset(edge: .top) {
            Text("Создание папки")
                .font(.title)
        }
        .safeAreaInset(edge: .bottom) {
            Button("Создать папку") {
                addFolderToStorage()
                dismiss()
            }
            .foregroundStyle(.white)
            .padding()
            .background(.gray)
            .clipShape(.rect(cornerRadius: 20))
        }
        
    }
    // MARK: Private methods
    private func addFolderToStorage() {
        let folder = Folder(context: managedObjectContext)
        folder.folderName = folderTitle
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
    FolderCreateView()
        .environmentObject(NotesManager.preview)
        .environment(
            \.managedObjectContext,
             PersistentConfigurator.preview.mainContext
        )
}
