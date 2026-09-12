//
//  Shift.swift
//  ShelfCheck
//
//  Created by Shashank Nayak on 11/9/2026.
//

import Foundation

/// A single work shift at the store ,the window of time one staff member
/// is rotated on. Expiry checks and handover notes are always tied to a
/// shift, since "already checked this shift" and "which shift is this note
/// going to" only make sense relative to one
struct Shift: Identifiable, Hashable {
    let shiftID: UUID
    let staff: StaffIdentifier
    let startedAt: Date
    let endedAt: Date?

    var id: UUID { shiftID }
    var isActive: Bool { endedAt == nil }

    /// Morning / Afternoon / Night how staff actually refer to shifts on
    /// the roster, based on when the shift started.
    var timeOfDaySlot: String {
        let hour = Calendar.current.component(.hour, from: startedAt)
        switch hour {
        case 5..<12: return "Morning"
        case 12..<17: return "Afternoon"
        default: return "Night"
        }
    }
}
