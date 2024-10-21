//
//  FileExportManager.swift
//  VoiceNote
//
//  Created by Pavel Kuznetsov on 19.10.2024.
//

import UIKit

/// Менеджер для экспорта текста заметок в .pdf/.txt файлы
struct FileExportManager {
    static func exportToTXT(_ text: NSAttributedString, _ title: String) -> URL? {
        let fileData = text.string.data(using: .utf8)
        guard let fileData else { return nil }
        return saveToTemporaryFile(fileData, "\(title).txt")
    }

    static func exportToPDF(_ text: NSAttributedString, _ title: String) -> URL? {
        let pageSize = CGSize(width: 595.2, height: 841.8)
            let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize))
            
            let pdfData = renderer.pdfData { context in
                context.beginPage()
                
                let titleAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 24),
                    .foregroundColor: UIColor.black
                ]
                
                let titleString = NSAttributedString(string: title, attributes: titleAttributes)
                
                // Document title
                let titleSize = titleString.size()
                let titleOrigin = CGPoint(x: (pageSize.width - titleSize.width) / 2, y: 40)
                titleString.draw(at: titleOrigin)
                
                // Main content
                let textStorage = NSTextStorage(attributedString: text)
                let layoutManager = NSLayoutManager()
                let textContainer = NSTextContainer(size: CGSize(width: pageSize.width - 40, height: pageSize.height - 80))
                layoutManager.addTextContainer(textContainer)
                textStorage.addLayoutManager(layoutManager)
                
                let textOrigin = CGPoint(x: 20, y: titleOrigin.y + titleSize.height + 20)
                
                let range = NSRange(location: 0, length: textStorage.length)
                layoutManager.drawBackground(forGlyphRange: range, at: textOrigin)
                layoutManager.drawGlyphs(forGlyphRange: range, at: textOrigin)
            }
            
        
        return saveToTemporaryFile(pdfData, "\(title).pdf")
    }
    
    static private func saveToTemporaryFile(_ data: Data, _ fileName: String) -> URL {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        do {
            try data.write(to: tempURL)
        } catch {
            print("Error writing to temporary file: \(error)")
        }
        return tempURL
    }
}
