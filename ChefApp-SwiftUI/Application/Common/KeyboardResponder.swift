//
//  KeyboardResponder.swift
//  Barback
//
//  Created by Alex Coundouriotis on 9/20/23.
//

import Foundation
import SwiftUI

final class KeyboardResponder: ObservableObject {
    private var notificationCenter: NotificationCenter
    @Published private(set) var currentHeight: CGFloat = 0

    init(center: NotificationCenter = .default) {
        notificationCenter = center
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    deinit {
        notificationCenter.removeObserver(self)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            // TODO: Did this bc I got this error - Publishing changes from within view updates is not allowed, this will cause undefined behavior.
            DispatchQueue.main.async {
                self.currentHeight = keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: Notification) {
        // TODO: Did this bc I got this error - Publishing changes from within view updates is not allowed, this will cause undefined behavior.
        DispatchQueue.main.async {
            self.currentHeight = 0
        }
    }
}
