//
//  VoiceNoteApp.swift
//  VoiceNote
//
//  Created by Pavel Kuznetsov on 02.10.2024.
//


import SwiftUI

@main
struct VoiceNoteApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    // MARK: - Shared models
    @StateObject var asrModel = ASRModel()
    @StateObject var notesManager = NotesManager(context: PersistentConfigurator.shared.persistentContainer.viewContext)
    @StateObject var audioManager = AudioManager()

    // MARK: - Environment
    @Environment(\.scenePhase) var scenePhase
    
    // MARK: - View body
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(
                    \.managedObjectContext,
                     PersistentConfigurator.shared.persistentContainer.viewContext
                )
                .environmentObject(asrModel)
                .environmentObject(notesManager)
                .environmentObject(audioManager)
                .onAppear {
                    notesManager.initializePredefinedCategories()
                }
        }
        .onChange(of: scenePhase) { _ in
              notesManager.save()
        }
    }
}
