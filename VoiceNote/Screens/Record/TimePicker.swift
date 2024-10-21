//
//  TimePicker.swift
//  VoiceNote
//
//  Created by Pavel Kuznetsov on 07.10.2024.
//


import SwiftUI

struct CustomTimePickerView: View {
    @Binding var higlightModel: NoteHighlightsModel
    var recordTime: TimeInterval
    
    var hoursCount: Int {
        recordTime.getUnitsCount(.hours)
    }
    
    var minutesCount: Int {
        recordTime.getUnitsCount(.minutes)
    }
    
    var secondsCount: Int {
        recordTime.getUnitsCount(.seconds)
    }
    
    // MARK: - View body
    var body: some View {
        VStack {
            HStack {
                // Начальная точка
                VStack {
                    Text("Начальная точка")
                    HStack {
                        Picker("Часы", selection: $higlightModel.startTs.hours) {
                            ForEach(Array(0...hoursCount), id: \.self) { hour in
                                Text("\(hour)").tag(hour)
                            }
                        }
                        Picker("Минуты", selection: $higlightModel.startTs.minutes) {
                            ForEach(Array(0...minutesCount), id: \.self) { minute in
                                Text(String(format: "%02d", minute)).tag(minute)
                            }
                        }
                        Picker("Секунды", selection: $higlightModel.startTs.seconds) {
                            ForEach(Array(0...secondsCount), id: \.self) { minute in
                                Text(String(format: "%02d", minute)).tag(minute)
                            }
                        }
                    }
                    .clipped()
                    .pickerStyle(.wheel)
                }
                Divider()
                // Конечная точка
                VStack {
                    Text("Конечная точка")
                    HStack {
                        Picker("Часы", selection: $higlightModel.endTs.hours) {
                            ForEach(Array(0...hoursCount), id: \.self) { hour in
                                Text("\(hour)").tag(hour)
                            }
                        }
                        Picker("Минуты", selection: $higlightModel.endTs.minutes) {
                            ForEach(Array(0...minutesCount), id: \.self) { minute in
                                Text(String(format: "%02d", minute)).tag(minute)
                            }
                        }
                        Picker("Секунды", selection: $higlightModel.endTs.seconds) {
                            ForEach(Array(0...secondsCount), id: \.self) { minute in
                                Text(String(format: "%02d", minute)).tag(minute)
                            }
                        }
                    }
                    .clipped()
                    .pickerStyle(.wheel)
                }
            }
            .padding()
            
            Text("Выбранный интервал: \(formattedTime)")
                .font(.headline)
                .padding()
        }
    }
    
    private var formattedTime: String {
        "\(higlightModel.startTs.totalTime) - \(higlightModel.endTs.totalTime)"
    }
}

#Preview {
    let testHighlightModel = NoteHighlightsModel(title: "", startTs: .init(hours: 0, minutes: 0, seconds: 40), endTs: .init(hours: 0, minutes: 2, seconds: 10))
    CustomTimePickerView(higlightModel: .constant(testHighlightModel), recordTime: 270)
}
