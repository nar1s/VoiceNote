//
//  MainView.swift
//  VoiceNote
//
//  Created by Pavel Kuznetsov on 02.10.2024.
//


import SwiftUI

struct MainView: View {
    @EnvironmentObject var asrModel: ASRModel
    @State private var searchText = ""
    @State var noteModels = NoteModel.mockedData
    @State private var isKeyboardActive: Bool = false
    @State private var needToShowRecordView: Bool = false
    @State private var needToShowASRAlert: Bool = false
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("ВСЕ ЗАМЕТКИ")) {
                    ForEach(noteModels) { model in
                        NavigationLink(value: model.id) {
                            Text(model.name)
                        }
                    }
                }
            }
            .navigationTitle("Заметки")
            .navigationDestination(for: UUID.self) { modelID in
                if let modelIndex = noteModels.firstIndex(where: { $0.id == modelID }) {
                    NoteView(noteModel: $noteModels[modelIndex])
                }
            }
        }
        .searchable(text: $searchText, prompt: "Введите название заметки, категории")
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
        .alert("Нужен доступ к распознаванию речи", isPresented: $needToShowASRAlert) {
            Button("В настройки", role: .cancel) {
                Task {
                    guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
                    await UIApplication.shared.open(settingsURL)
                }
            }
            Button("Закрыть", role: .destructive) {}
        }
        .overlay(alignment: .bottom) {
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
    }
}

#Preview {
    MainView()
        .environmentObject(ASRModel())
}
