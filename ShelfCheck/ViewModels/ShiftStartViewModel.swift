//
//  ShiftStartViewModel.swift
//  ShelfCheck
//
//  Created by Shashank Nayak on 13/9/2026.
//

import Foundation
import Combine

/// Drives the Shift Start screen this is a summary screen, not a
/// business operation, so it does not have its own Use Case. It pulls what
/// it needs from the existing Use Cases and repositories overdue warnings
/// from LogExpiryCheckUseCase, today's progress from
/// ReviewShiftComplianceUseCase, and the incoming notes and staff list
/// straight from their repositories, since listing them is not  a business
/// rule that needs protecting.
final class ShiftStartViewModel: ObservableObject {
    @Published private(set) var availableStaff: [StaffIdentifier] = []
    @Published private(set) var incomingNotes: [ShiftHandoverNote] = []
    @Published private(set) var checkedCategories: Set<ProductCategory> = []
    @Published private(set) var outstandingCategories: Set<ProductCategory> = Set(ProductCategory.allCases)
    @Published private(set) var overdueWarnings: [ExpiryCheckError] = []

    let session: ShiftSession

    private let staffRepository: StaffRepository
    private let shiftRepository: ShiftRepository
    private let noteRepository: HandoverNoteRepository
    private let logExpiryCheckUseCase: LogExpiryCheckUseCase
    private let reviewShiftComplianceUseCase: ReviewShiftComplianceUseCase

    init(
        staffRepository: StaffRepository,
        shiftRepository: ShiftRepository,
        noteRepository: HandoverNoteRepository,
        logExpiryCheckUseCase: LogExpiryCheckUseCase,
        reviewShiftComplianceUseCase: ReviewShiftComplianceUseCase,
        session: ShiftSession
    ) {
        self.staffRepository = staffRepository
        self.shiftRepository = shiftRepository
        self.noteRepository = noteRepository
        self.logExpiryCheckUseCase = logExpiryCheckUseCase
        self.reviewShiftComplianceUseCase = reviewShiftComplianceUseCase
        self.session = session

        availableStaff = staffRepository.allStaff()
        overdueWarnings = logExpiryCheckUseCase.overdueCategories()
        refreshIncomingNotes()
    }

    /// this is called when a staff member taps their name on the picker.
    func selectStaff(_ staff: StaffIdentifier) {
        session.startShift(for: staff)
        refreshTodaySummary()
    }

    /// Notes left by whoever was on the most recent shift that's ended.
    /// Called again whenever a shift ends, so the next person to sign in
    /// sees the note that was just written, not a stale one from launch.
    func refreshIncomingNotes() {
        let mostRecentEndedShift = shiftRepository.allShifts()
            .filter { $0.endedAt != nil }
            .max { ($0.endedAt ?? .distantPast) < ($1.endedAt ?? .distantPast) }

        guard let previousShift = mostRecentEndedShift else {
            incomingNotes = []
            return
        }
        incomingNotes = noteRepository.notes(forShiftID: previousShift.shiftID)
    }

    /// Refreshes what's been checked vs  outstanding for the current shift.
    /// A shift with nothing logged yet throws noDataForShift from the Use
    /// Case that is not an error worth showing here, it just means
    /// everything is still outstanding.
    func refreshTodaySummary() {
        guard let shiftID = session.currentShift?.shiftID else { return }
        do {
            let report = try reviewShiftComplianceUseCase.execute(shiftID: shiftID)
            checkedCategories = report.checkedCategories
            outstandingCategories = report.outstandingCategories
        } catch {
            checkedCategories = []
            outstandingCategories = Set(ProductCategory.allCases)
        }
    }
}
