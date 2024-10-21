//
//  MainView.swift
//  VoiceNote
//
//  Created by Pavel Kuznetsov on 02.10.2024.
//


import SwiftUI

struct MainView: View {
    // MARK: - Environment
    @EnvironmentObject var asrModel: ASRModel
    @EnvironmentObject var notesManager: NotesManager
    @Environment(\.managedObjectContext) var managedObjectContext
    
    // MARK: - Private properties
    @FetchRequest(sortDescriptors: [])
    var folders: FetchedResults<Folder>
    @FetchRequest(sortDescriptors: [])
    var notes: FetchedResults<Note>
    @State private var searchText = ""
    @State private var isKeyboardActive = false
    @State private var needToShowRecordView = false
    @State private var needToShowASRAlert = false
    @State private var needToShowFolderCreateView = false
    @State private var refreshID = UUID()
    
    var filteredNotes: [Note] {
        if searchText.isEmpty {
            return Array(notes)
        } else {
            return notes.filter {
                guard let name = $0.name else { return false }
                return name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                if !folders.isEmpty, searchText.isEmpty {
                    Section(header: Text("ПАПКИ")) {
                        ForEach(folders, id: \.self) { folder in
                            NavigationLink(value: folder) {
                                Text(folder.folderName ?? "")
                            }
                        }
                        .onDelete { indexSet in
                            deleteFolder(at: indexSet)
                        }
                    }
                }
                Section(header: Text("ВСЕ ЗАМЕТКИ")) {
                    if searchText.isEmpty {
                        if !notes.isEmpty {
                            ForEach(notes, id: \.self) { note in
                                NavigationLink(value: note) {
                                    Text(note.name ?? "")
                                }
                            }
                            .onDelete { indexSet in
                                deleteNote(at: indexSet)
                            }
                        } else {
                            Text("У вас пока нет заметок! \nДобавьте новую заметку через красную кнопку")
                        }
                    } else {
                        if !filteredNotes.isEmpty {
                            ForEach(filteredNotes, id: \.self) { note in
                                NavigationLink(value: note) {
                                    Text(note.name ?? "")
                                }
                            }
                        } else {
                            Text("По данному запросу ничего не найдено!")
                        }
                    }
                }
            }
            .id(refreshID)
            .onReceive(NotificationCenter.default.publisher(for: .NSPersistentStoreRemoteChange)) { _ in
                managedObjectContext.performAndWait {
                    managedObjectContext.refreshAllObjects()
                    try? managedObjectContext.save()
                }
                print("DEBUG: REFRESH ID")
                refreshID = UUID()
            }
            .navigationDestination(for: Note.self) { note in
                NoteView(noteModel: note)
            }
            .navigationDestination(for: Folder.self) { folder in
                FolderView(folder: folder)
            }
            .overlay(alignment: .bottom) {
                recordButton()
            }
            .navigationTitle("Заметки")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Image(systemName: "folder.fill.badge.plus")
                        .onTapGesture {
                            needToShowFolderCreateView = true
                        }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Введите название заметки, папки")
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            withAnimation {
                isKeyboardActive = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidHideNotification)) { _ in
            withAnimation {
                isKeyboardActive = false
            }
        }
        .fullScreenCover(isPresented: $needToShowRecordView) {
            RecordView()
        }
        .sheet(isPresented: $needToShowFolderCreateView) {
            FolderCreateView()
        }
        .alert("Нужен доступ к распознаванию речи", isPresented: $needToShowASRAlert) {
            Button("В настройки", role: .cancel) {
                Task {
                    guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
                    await UIApplication.shared.open(settingsURL)
                }
            }
            Button("Закрыть", role: .destructive) {}
        }
    }
    
    @ViewBuilder
    private func recordButton() -> some View {
        if !isKeyboardActive {
            HStack {
                Spacer()
                Button {
                    asrModel.getPermissionStatus { allowed in
                        if allowed {
                            needToShowRecordView = true
                        } else {
                            needToShowASRAlert = true
                        }
                    }
                } label: {
                    Circle()
                        .foregroundStyle(.red)
                        .frame(width: 60, height: 60)
                        .padding(.top)
                }
                Spacer()
            }
            .background(.ultraThinMaterial)
        }
    }
    
    private func deleteNote(at indexSet: IndexSet) {
        let notesToDelete = indexSet.map { notes[$0] }
        notesManager.deleteNote(notesToDelete)
    }
    
    private func deleteFolder(at indexSet: IndexSet) {
        let foldersToDelete = indexSet.map { folders[$0] }
        notesManager.deleteFolder(foldersToDelete)
    }
}

#Preview {
    let notesManager = NotesManager.preview
    MainView()
        .environmentObject(ASRModel())
        .environmentObject(AudioManager())
        .environment(
            \.managedObjectContext,
             PersistentConfigurator.preview.mainContext
        )
}
