//
//  AppDelegate.swift
//  VoiceNote
//
//  Created by Pavel Kuznetsov on 20.10.2024.
//

import UIKit
import CoreData

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
  ) -> Bool {
      NotificationCenter.default.addObserver(
          self,
          selector: #selector(storeRemoteChange(_:)),
          name: .NSPersistentStoreRemoteChange,
          object: PersistentConfigurator.shared.mainContext.persistentStoreCoordinator
      )
    return true
  }
    
    @objc func storeRemoteChange(_ notification: Notification) {
        print("DEBUG: NSPersistentStoreRemoteChange received")
        PersistentConfigurator.shared.mainContext.perform {
            PersistentConfigurator.shared.mainContext.mergeChanges(fromContextDidSave: notification)
        }
    }
}
