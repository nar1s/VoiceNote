//
//  Array+Extension.swift
//  VoiceNote
//
//  Created by Pavel Kuznetsov on 07.10.2024.
//

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
