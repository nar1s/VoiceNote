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
    @Published var isRecording: Bool = false
    
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
        isRecording = true
        setupUpdateTimer()
        print("DEBUG: Start recording")
    }
    
    func stopRecordingVoice() throws {
        audioRecorder?.stop()
        if let fileURL = audioRecorder?.url {
            print("DEBUG: Saved to \(fileURL)")
        }
        try resetASTModel()
        print("DEBUG: Stop recording")
    }
    
    func playPauseRecordingVoice() {
        if isRecording {
            audioRecorder?.pause()
            isRecording = false
        } else {
            audioRecorder?.record()
            isRecording = true
        }
    }
    
    func recognizeAudio(highlights: [NoteHighlightsModel], completion: @escaping (Result<ASRResult, Error>) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self else { return }
            guard let url = currentAudioURLPath else { return }
            guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "ru_RU")),
                  recognizer.isAvailable
            else {
                print("ERROR: \(#function) failed")
                return
            }
            let request = SFSpeechURLRecognitionRequest(url: url)
            recognizer.recognitionTask(with: request) { [weak self] result, error in
                if let error {
                    print(error.localizedDescription)
                    completion(.failure(error))
                    print("ERROR: \(error.localizedDescription)")
                    return
                }
                guard let result else {
                    print("ERROR: recognitionTask failed")
                    completion(.failure(ASRError.failed))
                    return
                }
                if result.isFinal {
                    print("SUCCESS: RECOGNITION OK")
                    print(result.bestTranscription.formattedString)
                    if let highlightedText = self?.generateHighlightedText(from: result.bestTranscription, with: highlights),
                       let url = self?.currentAudioURLPath {
                        DispatchQueue.main.async {
                            print("SUCCESS: MAIN QUEUE CALLBACK")
                            completion(.success(.init(formattedText: highlightedText, filePath: url.lastPathComponent)))
                            self?.currentAudioURLPath = nil
                        }
                    } else {
                        print("DEBUG: \(#function) FAIL")
                        completion(.failure(ASRError.failed))
                    }
                }
                return
            }
        }
    }
    
    func recognizeAndSaveAudio(_ fileURL: URL, completion: @escaping (Result<ASRResult, Error>) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self,
                  let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "ru_RU")),
                  recognizer.isAvailable
            else {
                print("ERROR: \(#function) failed")
                return
            }
            let request = SFSpeechURLRecognitionRequest(url: fileURL)
            recognizer.recognitionTask(with: request) { [weak self] result, error in
                if let error {
                    print(error.localizedDescription)
                    completion(.failure(error))
                    print("ERROR: \(error.localizedDescription)")
                    return
                }
                guard let result else {
                    print("ERROR: recognitionTask failed")
                    completion(.failure(ASRError.failed))
                    return
                }
                if result.isFinal {
                    print("SUCCESS: RECOGNITION OK")
                    print(result.bestTranscription.formattedString)
                    if let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.voiceNote.app"),
                       let highlightedText = self?.generateHighlightedText(from: result.bestTranscription, with: [])
                    {
                        let outputPath = appGroupURL
                            .appendingPathComponent(UUID().uuidString)
                            .appendingPathExtension("m4a")
                        try? FileManager.default.copyItem(at: fileURL, to: outputPath)
                        DispatchQueue.main.async {
                            print("SUCCESS: MAIN QUEUE CALLBACK")
                            print("DEBUG: SAVED URL \(outputPath)")
                            completion(
                                .success(
                                    .init(
                                        formattedText: highlightedText,
                                        filePath: outputPath.lastPathComponent
                                    )
                                )
                            )
                        }
                    }
                }
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
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
        ]
        if let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.voiceNote.app") {
            let outputPath = appGroupURL
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("m4a")
            do {
                audioRecorder = try AVAudioRecorder(url: outputPath, settings: recorderSettings)
            }
            catch {
                print("Failed to set up audio recorder: \(error.localizedDescription)")
            }
            audioRecorder?.prepareToRecord()
            currentAudioURLPath = outputPath
        } else {
            print("DEBUG: error creating path")
        }
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
    
    private func generateHighlightedText(from transcription: SFTranscription, with highlights: [NoteHighlightsModel]) -> NSAttributedString {
        let attributedText = NSMutableAttributedString()

        for segment in transcription.segments {
            let word = segment.substring
            let timestamp = segment.timestamp

            let wordAttributes: [NSAttributedString.Key: Any]
            
            if findHighlightForTimestamp(timestamp, highlights) {
                wordAttributes = [
                    .font: UIFont.boldSystemFont(ofSize: 16),
                    .foregroundColor: UIColor.black
                ]
            } else {
                wordAttributes = [
                    .font: UIFont.systemFont(ofSize: 16),
                    .foregroundColor: UIColor.black
                ]
            }

            let attributedWord = NSAttributedString(string: word, attributes: wordAttributes)

            attributedText.append(attributedWord)
            attributedText.append(NSAttributedString(string: " "))
        }

        return attributedText
    }
    
    private func findHighlightForTimestamp(_ timestamp: TimeInterval, _ highlights: [NoteHighlightsModel]) -> Bool {
        let (hours, minutes, seconds) = convertToTimeComponents(from: timestamp)
        for highlight in highlights {
            let highlightStart = highlight.startTs
            let highlightEnd = highlight.endTs
            
            if (hours >= highlightStart.hours && minutes >= highlightStart.minutes && seconds >= highlightStart.seconds) &&
               (hours <= highlightEnd.hours && minutes <= highlightEnd.minutes && seconds <= highlightEnd.seconds) {
                return true
            }
        }
        return false
    }
    
    private func convertToTimeComponents(from timeInterval: TimeInterval) -> (Int, Int, Int) {
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        let seconds = Int(timeInterval) % 60
        return (hours, minutes, seconds)
    }
    
    @objc private func updateCurrentRecordTime() {
        guard let currentTs = audioRecorder?.currentTime.rounded() else { return }
        currentRecordTime = currentTs
        print("DEBUG: Update time with value \(currentRecordTime)")
    }
}
