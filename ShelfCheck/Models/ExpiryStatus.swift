//
//  ExpiryStatus.swift
//  ShelfCheck
//
//  Created by Shashank Nayak on 11/9/2026.
//

import Foundation

/// This is outcome of checking a shelf section what the staff member actually
/// found when they looked. This is the result recorded against a check, not
/// just a pass fail here nearExpiry exists so staff can flag stock to rotate
/// to the front or pull soon, before it becomes  expired
enum ExpiryStatus: String, CaseIterable, Identifiable {
    case fresh = "Fresh"
    case nearExpiry = "Near expiry"
    case expired = "Expired"

    var id: String { rawValue }
}
