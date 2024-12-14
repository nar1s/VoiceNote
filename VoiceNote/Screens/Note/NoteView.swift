//
//  NoteView.swift
//  VoiceNote
//
//  Created by Pavel Kuznetsov on 04.10.2024.
//


import SwiftUI
import AVFoundation

struct NoteView: View {
    // MARK: - Environment
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var notesManager: NotesManager
    @EnvironmentObject var audioManager: AudioManager

    // MARK: - Public properties
    @State var noteModel: Note
    @State private var selectedCategory: String = "Личное"
    @State private var noteTitle: String = ""
    @State private var isNewlyCreated: Bool = false
    @State private var noteText: NSAttributedString = .init(string: "")
    @State private var isFocused: Bool = false
    @State private var isShareSheetPresented = false
    @State private var shareItems: [Any] = []
    @State private var showAlert = false
    @State private var alertMessage = ""
    var finishButtonAction: (() -> ())?
    
    // MARK: - Private properties
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name, order: .reverse)])
    private var categories: FetchedResults<Category>

    // MARK: View body
    var body: some View {
        ScrollViewReader { scrollViewProxy in
            Form {
                Section {
                    TextField("Введите название", text: $noteTitle)
                } header: {
                    Text("НАЗВАНИЕ")
                }
                Section {
                    HStack(spacing: 20) {
                        Button {
                            playPauseAudio()
                        } label: {
                            Image(systemName: audioManager.isPlaying ? "pause.circle" : "play.circle")
                                .resizable()
                                .frame(width: 40, height: 40)
                        }
                        Image(systemName: "waveform")
                            .resizable()
                    }
                } header: {
                    Text("АУДИОФАЙЛ")
                }
                Section {
                    Picker("Категория", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category.name ?? "").tag(category.name ?? "")
                        }
                    }
                } header: {
                    Text("КАТЕГОРИЯ")
                }
                Section {
                    List(getHighlights(), id: \.self) { highlight in
                        HStack {
                            Text(highlight.title + ":")
                            Spacer()
                            HStack {
                                Text(highlight.startTs.totalTime)
                                Image(systemName: "arrowshape.right")
                                Text(highlight.endTs.totalTime)
                            }
                        }
                    }
                } header: {
                    Text("ВРЕМЕННЫЕ МЕТКИ")
                }
                Section {
                    CustomTextField(attributedString: $noteText, isFocused: $isFocused)
                        .frame(height: 150)
                        .id("noteText")
                        .gesture(
                            DragGesture()
                                .onEnded { value in
                                    if value.translation.height > 50 {
                                        isFocused = false
//                                        UIApplication.shared.sendAction(
//                                            #selector(UIResponder.resignFirstResponder),
//                                            to: nil,
//                                            from: nil,
//                                            for: nil
//                                        )
                                    } else if value.translation.height < -50 {
                                        isFocused = false
//                                        UIApplication.shared.sendAction(
//                                            #selector(UIResponder.resignFirstResponder),
//                                            to: nil,
//                                            from: nil, for: nil
//                                        )
                                    }
                                }
                        )
                } header: {
                    Text("ТЕКСТ ЗАМЕТКИ")
                }
                HStack(alignment: .center) {
                    Spacer()
                    Button("Сохранить заметку") {
                        saveNoteToStorage()
                        if finishButtonAction == nil {
                            dismiss()
                        } else {
                            finishButtonAction?()
                        }
                    }
                    .padding()
                    .clipShape(.rect(cornerRadius: 20))
                    Spacer()
                }
            }
            .onChange(of: isFocused) { focused in
                if focused {
                    withAnimation {
                        scrollViewProxy.scrollTo("noteText", anchor: .top)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        if let text = noteModel.text, let title = noteModel.name {
                            Button("Экспорт в TXT") {
                                guard
                                    let url = FileExportManager.exportToTXT(text, title)
                                else { return }
                                shareItems = [url]
                                isShareSheetPresented = true
                            }
                            Button("Экспорт в PDF") {
                                guard
                                    let url = FileExportManager.exportToPDF(text, title)
                                else { return}
                                shareItems = [url]
                                isShareSheetPresented = true
                            }
                        }
                    } label: {
                        Image(systemName: "square.and.arrow.up.fill")
                            .imageScale(.large)
                            .foregroundStyle(.black)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(isNewlyCreated)
        .onAppear {
            updateView()
            guard let text = noteModel.text else { return }
            noteText = text
        }
        .sheet(isPresented: $isShareSheetPresented) {
            ActivityViewController(activityItems: $shareItems)
         }
        .onDisappear {
            audioManager.resetAudioSession()
        }
        .task {
            let timeInterval = Date.now.timeIntervalSince(noteModel.created ?? Date())
            isNewlyCreated = timeInterval <= 1
            guard let filePath = noteModel.relativeFilePath else { return }
            audioManager.configureAudioPlayer(with: filePath)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Ошибка"), message: Text(alertMessage), dismissButton: .default(Text("ОК")))
        }
    }
    
    private func playPauseAudio() {
        audioManager.playPauseAudio()
    }
    
    private func generateUniqueTitle(baseTitle: String) -> String {
        var uniqueTitle = baseTitle
        var counter = 1

        // Получаем все существующие названия заметок
        let existingTitles = notesManager.fetchAllNotes().compactMap { $0.name }

        // Проверяем, есть ли совпадения, и добавляем суффикс "(n)", пока не будет уникального названия
        while existingTitles.contains(uniqueTitle) {
            uniqueTitle = "\(baseTitle) (\(counter))"
            counter += 1
        }

        return uniqueTitle
    }

    private func saveNoteToStorage() {
        guard !noteTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                alertMessage = "Название заметки не может быть пустым."
                showAlert = true
                return
        }
        
        let uniqueTitle = generateUniqueTitle(baseTitle: noteTitle)
        
        noteModel.text = noteText
        noteModel.name = uniqueTitle
        noteModel.category = categories.first(where: { $0.name == selectedCategory })
        notesManager.save()
    }
    
    private func getHighlights() -> [NoteHighlightsModel] {
        let decoder = JSONDecoder()
        let highlights = try? decoder.decode([NoteHighlightsModel].self, from: noteModel.highlights ?? Data())
        return highlights ?? []
    }
    
    private func updateView() {
        noteTitle = noteModel.name ?? ""
        selectedCategory = noteModel.category?.name ?? ""
    }
}

#Preview {
    let note = Note.mockObject(context: PersistentConfigurator.preview.mainContext)
    NoteView(noteModel: note)
        .environmentObject(AudioManager())
}
