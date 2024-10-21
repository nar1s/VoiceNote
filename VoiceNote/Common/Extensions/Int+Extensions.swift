//
//  Int+Extensions.swift
//  VoiceNote
//
//  Created by Pavel Kuznetsov on 07.10.2024.
//


import UIKit

extension Int {
    func toTimeString() -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        if self >= 3600 {
            formatter.allowedUnits = [.hour, .minute, .second]
            formatter.zeroFormattingBehavior = .pad
        } else {
            formatter.allowedUnits = [.minute, .second]
            formatter.zeroFormattingBehavior = .pad
        }
        formatter.calendar?.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: TimeInterval(self)) ?? ""
    }
    
    func getUnitsCount(_ type: ConvertTimeType) -> Int {
        let count: Int
        switch type {
        case .hours: count = self / 3600
        case .minutes: count = (self % 3600) / 60
        case .seconds: count = self % 60
        }
        return count
    }
}

// MARK: - Helpers
extension Int {
    enum ConvertTimeType {
        case hours
        case minutes
        case seconds
    }
}
