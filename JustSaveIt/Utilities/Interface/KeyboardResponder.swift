//
//  KeyboardResponder.swift
//  JustSaveIt
//
//  Created by Kristiyan Butev on 25.04.21.
//

import SwiftUI

/*
 * Usage:
 * @ObservedObject private var keyboard = KeyboardResponder()
 *
 * View {}.padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
 * .padding(.bottom, keyboard.currentHeight)
 * .edgesIgnoringSafeArea(.bottom)
 * .animation(.easeOut(duration: 0.16))
 */
final class KeyboardResponder: ObservableObject {
    public static let shared = KeyboardResponder()
    
    private var notificationCenter: NotificationCenter
    @Published private(set) var currentHeight: CGFloat = 0

    init(center: NotificationCenter = .default) {
        notificationCenter = center
        notificationCenter.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    deinit {
        notificationCenter.removeObserver(self)
    }

    @objc func keyBoardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            currentHeight = keyboardSize.height
        }
    }

    @objc func keyBoardWillHide(notification: Notification) {
        currentHeight = 0
    }
}
