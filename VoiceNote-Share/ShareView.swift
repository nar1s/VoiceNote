//
//  ShareView.swift
//  VoiceNote
//
//  Created by Pavel Kuznetsov on 19.10.2024.
//


import SwiftUI
import CoreData
import UniformTypeIdentifiers

struct ShareView: View {
    // MARK: - Properties
    var extensionContext: NSExtensionContext?
    var asrModel: ASRModel
    @EnvironmentObject var noteManager: NotesManager
    
    @State private var needToShowLoader = true
    @State private var needToShowAlert = false
    @State private var navigationPath = NavigationPath()
    @State private var alertText: String = ""

    // MARK: - View body
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack {
                ProgressView()
                    .scaleEffect(3)
                    .progressViewStyle(.circular)
            }
            .ignoresSafeArea(.all)
            .navigationDestination(for: Note.self) { note in
                NoteView(noteModel: note) {
                    closeView()
                }
                .environment(\.managedObjectContext, PersistentConfigurator.shared.mainContext)
                .environmentObject(AudioManager())
            }
        }
        .task {
            await handleIncomingAudio()
        }
        .alert(isPresented: $needToShowAlert) {
            Alert(
                title: Text("Ошибка"),
                message: Text(alertText),
                dismissButton: .cancel { closeView() }
            )
        }
    }

    // MARK: Private methods
    private func closeView() {
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    func handleIncomingAudio() async {
        guard let item = extensionContext?.inputItems.first as? NSExtensionItem,
           let itemProvider = item.attachments?.first,
              itemProvider.hasItemConformingToTypeIdentifier(UTType.audio.identifier)
        else { return }
        
    
        do {
            let fileURL = try await itemProvider.loadItem(forTypeIdentifier: UTType.audio.identifier) as? URL
            guard let fileURL else { return }
            recognizeNote(fileURL)
        } catch {
            alertText = "Во время импорта файла произошла ошибка. Заметка не сохранена"
            needToShowAlert = true
        }
    }
    
    private func recognizeNote(_ fileURL: URL) {
        asrModel.recognizeAndSaveAudio(fileURL) { result in
            switch result {
            case .success(let result):
                print("DEBUG: SAVE TO CORE DATA \(result.filePath)")
                needToShowLoader = false
                Task {
                    navigationPath.append(await noteManager.createObject(result.formattedText, result.filePath))
                }
            case .failure:
                alertText = "Во время распознавания речи произошла ошибка. Заметка не сохранена"
                needToShowAlert = true
            }
        }
    }
}
