//
//  ManagerAcessViewModel.swift
//  ShelfCheck
//
//  Created by Shashank Nayak on 14/9/2026.
//

import Foundation
import Combine

/// A simple lock screen for the Manager Dashboard. It's just a shared
/// code everyone on the team knows, not a real login, more like a keypad
/// on a staff room door than actual security.
final class ManagerAccessViewModel: ObservableObject {
    @Published var enteredPIN: String = ""
    @Published private(set) var isUnlocked = false
    @Published var showIncorrectPINMessage = false

    private let correctPIN: String

    init(correctPIN: String = "1234") {
        self.correctPIN = correctPIN
    }

    func submitPIN() {
        if enteredPIN == correctPIN {
            isUnlocked = true
            showIncorrectPINMessage = false
        } else {
            showIncorrectPINMessage = true
        }
        enteredPIN = ""
    }

    func lock() {
        isUnlocked = false
    }
}
