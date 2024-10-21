//
//  ActivityViewController.swift
//  VoiceNote
//
//  Created by Pavel Kuznetsov on 19.10.2024.
//

import SwiftUI

struct ActivityViewController: UIViewControllerRepresentable {
    @Binding var activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
