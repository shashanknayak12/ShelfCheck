//
//  InMemoryShelfChekStore.swift
//  ShelfCheck
//
//  Created by Shashank Nayak on 13/9/2026.
//

import Foundation

/// A single in memory data store standing in for a backend, for this MVP.
/// All 4 repository protocols point at the same shared state here, so a
/// check logged from one screen shows up immediately from another  the
/// same way one shared paper log would, just live instead of on paper.
///
/// This is a class rather than a struct deliberately very ViewModel in
/// the app needs to see the same data not the copy of it.
final class InMemoryShelfCheckStore: StaffRepository, ShiftRepository, ExpiryCheckRepository, HandoverNoteRepository {
    private var staffRoster: [StaffIdentifier]
    private var shifts: [Shift]
    private var checks: [ExpiryCheckRecord]
    private var notes: [ShiftHandoverNote]

    init() {
        let jordan = StaffIdentifier(staffID: UUID(), name: "Jordan")
        let sam = StaffIdentifier(staffID: UUID(), name: "Sam")
        let priya = StaffIdentifier(staffID: UUID(), name: "Priya")
        let liam = StaffIdentifier(staffID: UUID(), name: "Liam")
        let chen = StaffIdentifier(staffID: UUID(), name: "Chen")
        staffRoster = [jordan, sam, priya, liam, chen]

        let calendar = Calendar.current
        let previousShiftStart = calendar.date(byAdding: .hour, value: -10, to: Date()) ?? Date()
        let previousShiftEnd = calendar.date(byAdding: .hour, value: -2, to: Date()) ?? Date()
        let previousShift = Shift(shiftID: UUID(), staff: sam, startedAt: previousShiftStart, endedAt: previousShiftEnd)
        shifts = [previousShift]

        checks = [
            ExpiryCheckRecord(
                checkID: UUID(), shiftID: previousShift.shiftID, productCategory: .dairy,
                checkedBy: sam, checkedAt: previousShiftStart.addingTimeInterval(600), expiryStatus: .fresh
            ),
            ExpiryCheckRecord(
                checkID: UUID(), shiftID: previousShift.shiftID, productCategory: .hotFood,
                checkedBy: sam, checkedAt: previousShiftStart.addingTimeInterval(1200), expiryStatus: .fresh
            ),
            ExpiryCheckRecord(
                checkID: UUID(), shiftID: previousShift.shiftID, productCategory: .drinks,
                checkedBy: sam, checkedAt: previousShiftStart.addingTimeInterval(1800), expiryStatus: .nearExpiry
            )
        ]

        notes = [
            ShiftHandoverNote(
                noteID: UUID(),
                fromShiftID: previousShift.shiftID,
                authoredBy: sam,
                message: "Didn't get to chocolate and gum sections tonight — please check first thing, found expired stock there last week.",
                flaggedCategory: .chocolate,
                createdAt: previousShiftEnd
            )
        ]
    }

    

    func allStaff() -> [StaffIdentifier] {
        staffRoster
    }

    

    func shift(withID shiftID: UUID) -> Shift? {
        shifts.first { $0.shiftID == shiftID }
    }

    func allShifts() -> [Shift] {
        shifts
    }

    func save(_ shift: Shift) {
        if let index = shifts.firstIndex(where: { $0.shiftID == shift.shiftID }) {
            shifts[index] = shift
        } else {
            shifts.append(shift)
        }
    }

   

    func save(_ record: ExpiryCheckRecord) {
        checks.append(record)
    }

    func checks(forShiftID shiftID: UUID) -> [ExpiryCheckRecord] {
        checks.filter { $0.shiftID == shiftID }
    }

    func mostRecentCheck(for category: ProductCategory) -> ExpiryCheckRecord? {
        checks
            .filter { $0.productCategory == category }
            .max { $0.checkedAt < $1.checkedAt }
    }


    func save(_ note: ShiftHandoverNote) {
        notes.append(note)
    }

    func notes(forShiftID shiftID: UUID) -> [ShiftHandoverNote] {
        notes.filter { $0.fromShiftID == shiftID }
    }

    func allNotes() -> [ShiftHandoverNote] {
        notes
    }
}
