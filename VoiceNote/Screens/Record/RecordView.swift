//
//  RecordView.swift
//  VoiceNote
//
//  Created by Pavel Kuznetsov on 04.10.2024.
//


import SwiftUI

struct RecordView: View {
    // MARK: - Environment
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var asrModel: ASRModel
    
    // MARK: - Private properties
    @State private var needToShowLoader: Bool = false
    @State private var needToShowAlert: Bool = false
    @State private var path = NavigationPath()
    
    // MARK: - View body
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                Text( TimeFormatter.convertToTimeString($asrModel.currentRecordTime.wrappedValue))
                    .font(.title    )
                Spacer()
                Image(systemName: "waveform")
                    .resizable()
                    .frame(width: 300, height: 300)
                    .padding()
                Spacer()
                HStack(spacing: 120) {
                    Button {
                        // TODO: add highlight
                    } label: {
                        Image(systemName: "pencil.tip.crop.circle.badge.plus")
                            .resizable()
                            .frame(width: 70, height: 60)
                            .foregroundStyle(.black)
                    }
                    Button {
                        // TODO: add stopresume
                    } label: {
                        Image(systemName: "pause.circle")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundStyle(.black)
                    }
                }
                Spacer()
                Button("Остановить запись") {
                    needToShowLoader = true
                    stopRecording()
                }
                .foregroundStyle(.white)
                .padding()
                .background(.red)
                .clipShape(.rect(cornerRadius: 20))
            }
            .navigationTitle("Новая заметка")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: NoteModel.self) { model in
                NoteView(noteModel: .constant(model),isNewlyCreated: true) {
                    dismiss()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        stopRecording()
                        dismiss()
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(.black)
                            .imageScale(.large)
                            .rotationEffect(.degrees(45))
                            .padding()
                    }
                }
            }
        }
        .alert(isPresented: $needToShowAlert) {
            Alert(
                title: Text("Ошибка"),
                message: Text("Во время распознавания речи произошла ошибка. Заметка не сохранена"),
                dismissButton: .cancel { dismiss() }
            )
        }
        .task {
            do {
                try asrModel.setupASRModel()
            } catch {
                print(error.localizedDescription)
                dismiss()
            }
        }
        .overlay {
            if needToShowLoader || asrModel.sessionSetupInProgress {
                GeometryReader { proxy in
                    VStack {
                        ProgressView()
                            .scaleEffect(3)
                            .progressViewStyle(.circular)
                    }
                    .frame(width: proxy.size.width, height: proxy.size.height)
                }
                .ignoresSafeArea(.all)
                .background(.ultraThinMaterial)
            }
        }
    }
    // MARK: - Private methods
    private func stopRecording() {
        do {
            try asrModel.stopRecordingVoice()
            asrModel.recognizeAudio { result in
                switch result {
                case .success(let recognizedText):
                    // TODO: передать URL
                    path.append(NoteModel(name: "", text: AttributedString(recognizedText), categoty: .education, audioFilePath: nil, highligts: []))
                    needToShowLoader = false
                case .failure:
                    needToShowAlert = true
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

#Preview {
    RecordView()
        .environmentObject(ASRModel())
}
