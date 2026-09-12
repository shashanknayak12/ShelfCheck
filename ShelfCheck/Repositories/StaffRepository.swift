//
//  StaffRepository.swift
//  ShelfCheck
//
//  Created by Shashank Nayak on 13/9/2026.
//

import Foundation

/// The roster of the 5 casual staff who share the app. This is what the
/// staff picker on the Shift Start screen reads from  there is no login,
/// just a fixed list of names to choose from.
protocol StaffRepository {
    func allStaff() -> [StaffIdentifier]
}
