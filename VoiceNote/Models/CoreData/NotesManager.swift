//
//  NotesManager.swift
//  VoiceNote
//
//  Created by Pavel Kuznetsov on 14.10.2024.
//

import CoreData

final class NotesManager: ObservableObject {
    // MARK: - Public properties
    var context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }
    

    // MARK: - Public methods
    func save() {
        if context.hasChanges {
            do {
                try context.save()
                print("DEBUG: Save succeeded in CORE DATA")
            } catch {
                print("Error saving Core Data: \(error.localizedDescription)")
                context.rollback()
            }
        } else {
            print("Error saving Core Data: context dosen't have changes")
        }
    }
    
    func createObject(_ text: NSAttributedString, _ path: String) async -> Note {
        await context.perform {
            let noteModel = Note(context: self.context)
            noteModel.name = "Новая заметка"
            noteModel.text = text
            noteModel.noteID = UUID()
            noteModel.highlights = Data()
            noteModel.relativeFilePath = path
            noteModel.created = Date.now
            return noteModel
        }
    }
    
    func deleteNote(_ notes: [Note]) {
        guard let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.voiceNote.app") else {
            print("DEBUG: App Group not found")
            return
        }
        notes.forEach {
            context.delete($0)
            guard let relativeFilePath = $0.relativeFilePath else { return }
            let fileURL = appGroupURL.appendingPathComponent(relativeFilePath)
            do {
                try FileManager.default.removeItem(at: fileURL)
                print("DEBUG: SUCCESS DELETE NOTE AT \(fileURL)")
            } catch {
                print("DEBUG: ERROR DELETE NOTE AT \(fileURL)")
            }
        }
        save()
    }

    func deleteFolder(_ folders: [Folder]) {
        folders.forEach { context.delete($0) }
        save()
    }
    
    func initializePredefinedCategories() {
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        do {
            let count = try context.count(for: fetchRequest)
            if count == 0 {
                let categories = [
                    "Работа",
                    "Личное",
                    "Образование"
                ]
                
                for categoryName in categories {
                    let category = Category(context: context)
                    category.name = categoryName
                }
                save()
                print("DEBUG: Predefined categories saved to Core Data.")
            } else {
                print("DEBUG: Categories already exist, no need to add them.")
            }
        } catch {
            print("DEBUG: Failed initializePredefinedCategories(): \(error)")
        }
    }
}

// MARK: - Preview model
extension NotesManager {
    static var preview: NotesManager = {
        let context = PersistentConfigurator.preview.mainContext
        let manager = NotesManager(context: context)
        let folder = Folder(context: context)
        folder.folderName = "Записи лекций"
        let category = Category(context: context)
        category.name = "Тестовая"
        
        for i in 0..<5 {
            let note = Note(context: context)
            note.name = "Новая заметка"
            note.text = NSAttributedString(string: "Описание заметки")
            note.noteID = UUID()
            note.highlights = Data()
            note.relativeFilePath = "path/to/file"
            category.addToNote(note)
            folder.addToNote(note)
        }
        return manager
    }()
}


extension Note {
    static func mockObject(context: NSManagedObjectContext) -> Note {
        let note = Note(context: context)
        note.name = "Новая заметка"
        note.text = NSAttributedString(string: "Описание заметки")
        note.noteID = UUID()
        note.highlights = Data()
        note.relativeFilePath = "path/to/file"
        return note
    }
}

extension Folder {
    static func mockObject(context: NSManagedObjectContext) -> Folder {
        let note = Note(context: context)
        note.name = "Заметка в папке"
        note.text = NSAttributedString(string: "Описание заметки")
        note.noteID = UUID()
        note.highlights = Data()
        note.relativeFilePath = "path/to/file"
        let folder = Folder(context: context)
        folder.addToNote(note)
        return folder
    }
}
