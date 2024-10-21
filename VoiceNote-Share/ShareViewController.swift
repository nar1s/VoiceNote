//
//  ShareViewController.swift
//  VoiceNote-Share
//
//  Created by Pavel Kuznetsov on 19.10.2024.
//


import SwiftUI
import CoreData

@objc(ShareViewController)
class ShareViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func setupView() {
        let hostingView = UIHostingController(
            rootView:
                ShareView(
                    extensionContext: extensionContext,
                    asrModel: ASRModel()
                )
                .environmentObject(NotesManager(context: PersistentConfigurator.shared.mainContext))
        )
        addChild(hostingView)
        view.addSubview(hostingView.view)
        hostingView.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingView.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            hostingView.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            hostingView.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            hostingView.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
    }
}
