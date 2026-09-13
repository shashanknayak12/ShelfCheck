//
//  ShiftSession.swift
//  ShelfCheck
//
//  Created by Shashank Nayak on 13/9/2026.
//

import Foundation
import Combine

/// Tracks who is currently signed in on this device and what shift they are
/// on. Set once when a staff member picks their name at Shift Start, then
/// read by the Checklist and Handover screens so every check or note gets
/// attached to the right person and the right shift
final class ShiftSession: ObservableObject {
    @Published private(set) var currentStaff: StaffIdentifier?
    @Published private(set) var currentShift: Shift?

    private let shiftRepository: ShiftRepository

    init(shiftRepository: ShiftRepository) {
        self.shiftRepository = shiftRepository
    }

    func startShift(for staff: StaffIdentifier) {
        let shift = Shift(shiftID: UUID(), staff: staff, startedAt: Date(), endedAt: nil)
        shiftRepository.save(shift)
        currentStaff = staff
        currentShift = shift
    }

    func endShift() {
        guard let shift = currentShift else { return }
        let endedShift = Shift(
            shiftID: shift.shiftID,
            staff: shift.staff,
            startedAt: shift.startedAt,
            endedAt: Date()
        )
        shiftRepository.save(endedShift)
        currentStaff = nil
        currentShift = nil
    }
}
