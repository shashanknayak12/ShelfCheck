//
//  ShiftDetailViewModel.swift
//  ShelfCheck
//
//  Created by Shashank Nayak on 14/9/2026.
//

import Foundation
import Combine

/// shows  the Shift Detail screen, what a manager sees after tapping into
/// one shift from the dashboard. It takes the ShiftComplianceReport the
/// dashboard already computed rather than recalculating it, and just reads
/// the raw checks and notes for that shift directly for display, same
/// reasoning as the Shift Start screen, listing them isn't a business
/// rule needing protection.
final class ShiftDetailViewModel: ObservableObject {
    let report: ShiftComplianceReport
    @Published private(set) var checks: [ExpiryCheckRecord] = []
    @Published private(set) var notes: [ShiftHandoverNote] = []

    private let checkRepository: ExpiryCheckRepository
    private let noteRepository: HandoverNoteRepository

    init(
        report: ShiftComplianceReport,
        checkRepository: ExpiryCheckRepository,
        noteRepository: HandoverNoteRepository
    ) {
        self.report = report
        self.checkRepository = checkRepository
        self.noteRepository = noteRepository

        checks = checkRepository
            .checks(forShiftID: report.shift.shiftID)
            .sorted { $0.checkedAt < $1.checkedAt }
        notes = noteRepository.notes(forShiftID: report.shift.shiftID)
    }
}
