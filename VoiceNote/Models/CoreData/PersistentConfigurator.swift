//
//  PersistentConfigurator.swift
//  VoiceNote
//
//  Created by Pavel Kuznetsov on 19.10.2024.
//


import CoreData

final class PersistentConfigurator {
    static let shared = PersistentConfigurator()
    static let preview = PersistentConfigurator(inMemory: true)
    private let inMemory: Bool
    
    private init(inMemory: Bool = false) {
        self.inMemory = inMemory
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "NoteData")
        if let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.voiceNote.app") {
            let storeURL = appGroupURL.appendingPathComponent("YourModel.sqlite")
            let storeDescription = NSPersistentStoreDescription(url: storeURL)
            storeDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
            container.persistentStoreDescriptions = [storeDescription]
            if inMemory {
                container.persistentStoreDescriptions.first?.url = URL(
                    fileURLWithPath: "/dev/null"
                )
            }
        } else {
            fatalError("App Group not found")
        }
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        return container
    }()
    
    var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    lazy var backgroundContext: NSManagedObjectContext = {
        persistentContainer.newBackgroundContext()
    }()

}
