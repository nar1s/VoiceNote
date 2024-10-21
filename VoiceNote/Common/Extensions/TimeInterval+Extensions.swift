//
//  TimeInterval+Extensions.swift
//  VoiceNote
//
//  Created by Pavel Kuznetsov on 06.10.2024.
//

import UIKit

extension TimeInterval {
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
        return formatter.string(from: self) ?? ""
    }
    
    func getUnitsCount(_ type: ConvertTimeType) -> Int {
        let count: Int
        switch type {
        case .hours: count = Int(self / 3600)
        case .minutes: count = (Int(self) % 3600) / 60
        case .seconds: count = Int(self) % 60
        }
        return count
    }
    
    func convertToTimeComponents() -> TimeComponents {
        var components = TimeComponents()
        components.hours = self.getUnitsCount(.hours)
        components.minutes = self.getUnitsCount(.minutes)
        components.seconds = self.getUnitsCount(.seconds)
        return components
    }
}

// MARK: - Helpers
extension TimeInterval {
    enum ConvertTimeType {
        case hours
        case minutes
        case seconds
    }
}
