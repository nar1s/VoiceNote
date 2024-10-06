//
//  SpeechRecognitionModel.swift
//  VoiceNote
//
//  Created by Pavel Kuznetsov on 05.10.2024.
//

import UIKit
import Speech


final class ASRModel: ObservableObject {
    // MARK: - Public properties
    @Published var currentRecordTime: TimeInterval = 0
    @Published var sessionSetupInProgress: Bool = false
    
    // MARK: - Private properties
    private var recordingSession: AVAudioSession?
    private var audioRecorder: AVAudioRecorder?
    private var updateTimer: Timer?
    private var currentAudioURLPath: URL?
    
    // MARK: - Public methods
    func setupASRModel() throws {
        sessionSetupInProgress = true
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try self.setupAudioSession()
                try self.setupAudioRecorder()
                DispatchQueue.main.async { [weak self] in
                    print("DEBUG: Audio setup completed")
                    self?.sessionSetupInProgress = false
                    self?.startRecordingVoice()
                }
            } catch {
                DispatchQueue.main.async {
                    print("DEBUG: Audio setup failed with error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func resetASTModel() throws {
        try recordingSession?.setActive(false)
        recordingSession = nil
        audioRecorder = nil
        currentRecordTime = 0
        updateTimer?.invalidate()
        updateTimer = nil
        sessionSetupInProgress = false
    }
    
    func getPermissionStatus(completion: @escaping (Bool) -> ()) {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            guard granted else {
                completion(false)
                return
            }
            SFSpeechRecognizer.requestAuthorization { authStatus in
                switch authStatus {
                case .authorized: completion(true)
                default:completion(false)
                }
            }
        }
    }
    
    func startRecordingVoice() {
        audioRecorder?.record()
        setupUpdateTimer()
        print("DEBUG: Start recording")
    }
    
    func stopRecordingVoice() throws {
        audioRecorder?.stop()
        print("DEBUG: Saved to \(audioRecorder?.url)")
        currentAudioURLPath = audioRecorder?.url
        try resetASTModel()
        print("DEBUG: Stop recording")
    }
    
    func recognizeAudio(completion: @escaping (Result<String, Error>) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self else { return }
            guard let url = currentAudioURLPath else { return }
            guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "ru_RU")),
                  recognizer.isAvailable
            else { return }
            let request = SFSpeechURLRecognitionRequest(url: url)
            recognizer.recognitionTask(with: request) { [weak self] result, error in
                if let error {
                    print(error.localizedDescription)
                    completion(.failure(error))
                    return
                }
                guard let result else {
                    print("ERROR: recognitionTask failed")
                    completion(.failure(ASRError.failed))
                    return
                }
                if result.isFinal {
                    print(result.bestTranscription.formattedString)
                    DispatchQueue.main.async {
                        completion(.success(result.bestTranscription.formattedString))
                    }
                }
                self?.currentAudioURLPath = nil
                return
            }
        }
    }
    
    // MARK: - Private methods
    private func setupAudioSession() throws {
        recordingSession = AVAudioSession.sharedInstance()
        try recordingSession?.setCategory(.playAndRecord, mode: .default)
        try recordingSession?.setActive(true)
    }
    
    private func setupAudioRecorder() throws {
        let recorderSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        let outputPath = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension(for: .mpeg4Audio)
        audioRecorder = try AVAudioRecorder(url: outputPath, settings: recorderSettings)
        audioRecorder?.prepareToRecord()
    }
    
    private func setupUpdateTimer() {
        updateTimer = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(updateCurrentRecordTime),
            userInfo: nil,
            repeats: true
        )
    }
    
    @objc private func updateCurrentRecordTime() {
        guard let currentTs = audioRecorder?.currentTime.rounded() else { return }
        currentRecordTime = currentTs
        print("DEBUG: Update time with value \(currentRecordTime)")
    }
}
