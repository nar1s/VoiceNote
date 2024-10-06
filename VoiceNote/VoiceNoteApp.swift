//
//  VoiceNoteApp.swift
//  VoiceNote
//
//  Created by Pavel Kuznetsov on 02.10.2024.
//


import SwiftUI

@main
struct VoiceNoteApp: App {
    // MARK: - Shared models
    @StateObject var asrModel = ASRModel()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(asrModel)
        }
    }
}
