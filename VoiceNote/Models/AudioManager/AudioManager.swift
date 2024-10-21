//
//  AudioManager.swift
//  VoiceNote
//
//  Created by Pavel Kuznetsov on 15.10.2024.
//


import AVFoundation
import Combine

class AudioManager: NSObject, AVAudioPlayerDelegate, ObservableObject {
    @Published var isPlaying = false
    private var audioPlayer: AVAudioPlayer?

    func configureAudioPlayer(with relativeFilePath: String) {
        configureAudioSession()
        guard let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.voiceNote.app") else {
            print("DEBUG: App Group not found")
            return
        }
        let fileURL = appGroupURL.appendingPathComponent(relativeFilePath)
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
                audioPlayer?.delegate = self
                audioPlayer?.prepareToPlay()
            } catch {
                print("Failed to initialize audio player: \(error)")
            }
        }
    }

    func playPauseAudio() {
        if isPlaying {
            audioPlayer?.pause()
        } else {
            audioPlayer?.play()
        }
        isPlaying.toggle()
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
    }
    
    func resetAudioSession() {
        isPlaying = false
        audioPlayer?.stop()
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.overrideOutputAudioPort(.none)
            try audioSession.setActive(false)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [])
            try audioSession.setActive(true)
            try audioSession.overrideOutputAudioPort(.speaker)
        } catch {
            print("DEBUG: failed configureAudioSession \(error.localizedDescription)")
        }
    }
}
