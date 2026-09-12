//
//  StaffIdentifier.swift
//  ShelfCheck
//
//  Created by Shashank Nayak on 11/9/2026.
//

import Foundation

/// Identifies a member of the store's casual staff roster.
///
///
///
/// There is  no login here  staff just pick their name from a list at the
/// start of a shift. This gets attached to every check and note they log,
/// so it is always clear who did what
struct StaffIdentifier: Identifiable, Hashable {
    let staffID: UUID
    let name: String

    var id: UUID { staffID }
}
