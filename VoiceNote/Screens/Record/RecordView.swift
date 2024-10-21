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
    @Environment(\.managedObjectContext) var managedObjectContext
    
    // MARK: - Private properties
    @State private var needToShowLoader: Bool = false
    @State private var needToShowAlert: Bool = false
    @State private var needToShowTimePicker: Bool = false
    @State private var path = NavigationPath()
    @State private var selectedHighlightModelIndex: Int?
    @State private var isHighlighting: Bool = false
    @State private var highlightsModel: [NoteHighlightsModel] = []
    
    // MARK: - View body
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                Text($asrModel.currentRecordTime.wrappedValue.toTimeString())
                    .font(.title)
                Spacer()
                Image(systemName: "waveform")
                    .resizable()
                    .frame(width: 300, height: 150)
                    .padding()
                Spacer()
                HStack(spacing: 120) {
                    if !isHighlighting {
                        Button {
                            startHighlightFromCurrentTs()
                        } label: {
                            Image(systemName: "pencil.tip.crop.circle.badge.plus")
                                .resizable()
                                .frame(width: 70, height: 60)
                        }
                    } else {
                        Button {
                            stopHighlight()
                        } label: {
                            Image(systemName: "pencil.tip.crop.circle.badge.arrow.forward")
                                .resizable()
                                .frame(width: 70, height: 60)
                        }
                    }

                    Button {
                        asrModel.playPauseRecordingVoice()
                    } label: {
                        Image(systemName: asrModel.isRecording ? "pause.circle" : "play.circle")
                            .resizable()
                            .frame(width: 60, height: 60)
                    }
                }
                Spacer()
                if !highlightsModel.isEmpty {
                    VStack {
                        Text("Временные метки")
                            .font(.title2)
                            .padding(.top)
                        List(highlightsModel.indices, id: \.self) { index in
                            HStack {
                                TextField("Название интервала", text: $highlightsModel[index].title)
                                Text(highlightsModel[index].startTs.totalTime)
                                    .onTapGesture {
                                        needToShowTimePicker = true
                                    }
                                if !highlightsModel[index].endTs.isEmpty {
                                    Image(systemName: "arrowshape.right")
                                    Text($highlightsModel[index].endTs.wrappedValue.totalTime)
                                        .onTapGesture {
                                            needToShowTimePicker = true
                                        }
                                }
                            }
                        }
                    }
                }
            }
            .navigationDestination(for: Note.self) { note in
                NoteView(noteModel: note) {
                    dismiss()
                }
            }
            .navigationTitle("Новая заметка")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                Button("Остановить запись") {
                    needToShowLoader = true
                    stopRecording()
                }
                .foregroundStyle(.white)
                .padding()
                .background(.red)
                .clipShape(.rect(cornerRadius: 20))
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        stopRecording()
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
        .sheet(isPresented: $needToShowTimePicker) {
            CustomTimePickerView(
                higlightModel: $highlightsModel[selectedHighlightModelIndex ?? 0],
            recordTime: asrModel.currentRecordTime
            )
                .presentationDetents([.fraction(0.25)])
        }
    }
    // MARK: - Private methods
    private func stopRecording() {
        stopHighlight()
        do {
            try asrModel.stopRecordingVoice()
            asrModel.recognizeAudio(highlights: highlightsModel) { result in
                switch result {
                case .success(let result):
                    print("DEBUG: SAVE TO CORE DATA \(result.filePath)")
                    let noteModel = Note(context: managedObjectContext)
                    noteModel.name = "Новая заметка"
                    noteModel.text = result.formattedText
                    noteModel.noteID = UUID()
                    noteModel.highlights = convertHightlightsToData(highlightsModel)
                    noteModel.relativeFilePath = result.filePath
                    noteModel.created = Date.now
                    path.append(noteModel)
                    needToShowLoader = false
                case .failure:
                    needToShowAlert = true
                }
            }
        } catch {
            print("DEBUG: failed to stop recording: \(error.localizedDescription)")
        }
    }
    
    private func startHighlightFromCurrentTs() {
        let currentTs = asrModel.currentRecordTime
        withAnimation {
            highlightsModel.append(
                .init(
                    title: "Новый интервал",
                    startTs: currentTs.convertToTimeComponents(),
                    endTs: .init()
                )
            )
            isHighlighting = true
        }
    }
    
    private func stopHighlight() {
        let currentTs = asrModel.currentRecordTime
        withAnimation {
            if !highlightsModel.isEmpty {
                let lastIndex = highlightsModel.count - 1
                if highlightsModel[lastIndex].endTs.isEmpty {
                    highlightsModel[lastIndex].endTs = currentTs.convertToTimeComponents()
                }
            }
            isHighlighting = false
        }
    }

    private func convertHightlightsToData(_ highlights: [NoteHighlightsModel]) -> Data {
        let encoder = JSONEncoder()
        let highlightsData = try? encoder.encode(highlights)
        return highlightsData ?? Data()
    }
}

#Preview {
    RecordView()
        .environmentObject(ASRModel())
}
