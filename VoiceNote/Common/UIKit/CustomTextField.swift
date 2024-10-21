//
//  CustomTextField.swift
//  VoiceNote
//
//  Created by Pavel Kuznetsov on 15.10.2024.
//

import SwiftUI

struct CustomTextField: UIViewRepresentable {
    @Binding var attributedString: NSAttributedString
    @Binding var isFocused: Bool
    
    var defaultAttributes: [NSAttributedString.Key: Any] {
         return [
             .font: UIFont.systemFont(ofSize: 16),
             .foregroundColor: UIColor.black
         ]
     }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.isEditable = true
        textView.attributedText = attributedString
        textView.returnKeyType = .default
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = attributedString
        if uiView.isFirstResponder {
             isFocused = true
         } else {
             isFocused = false
         }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: CustomTextField

        init(_ parent: CustomTextField) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            guard let currentAttributedString = textView.attributedText else { return }
            
            let mutableAttributedString = NSMutableAttributedString(attributedString: currentAttributedString)
            
            if let newText = textView.text {
                let newLength = newText.count
                let rangeToUpdate = NSRange(location: newLength - 1, length: 1)
                
                if newLength > 0 {
                    mutableAttributedString.addAttributes(parent.defaultAttributes, range: rangeToUpdate)
                }
            }
            
            parent.attributedString = mutableAttributedString
        }
    }
}
