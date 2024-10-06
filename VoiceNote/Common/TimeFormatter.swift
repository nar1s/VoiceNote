//
//  TimeFormatter.swift
//  VoiceNote
//
//  Created by Pavel Kuznetsov on 06.10.2024.
//

import UIKit

struct TimeFormatter {
    static func convertToTimeString(_ time: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour]
        formatter.unitsStyle = .abbreviated
        formatter.calendar?.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: time) ?? ""
    }
}
