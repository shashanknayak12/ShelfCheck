//
//  LogExpiryCheckUseCaseTests.swift
//  ShelfCheckTests
//
//  Created by Shashank Nayak on 14/9/2026.
//

import XCTest
@testable import ShelfCheck

/// Shared test doubles for the repository protocols, used across all 3
/// Use Case test files in this target. Kept here since it's the first
/// test file, plain arrays standing in for a database, no persistence.

final class MockExpiryCheckRepository: ExpiryCheckRepository {
    private(set) var savedRecords: [ExpiryCheckRecord] = []

    func save(_ record: ExpiryCheckRecord) {
        savedRecords.append(record)
    }

    func checks(forShiftID shiftID: UUID) -> [ExpiryCheckRecord] {
        savedRecords.filter { $0.shiftID == shiftID }
    }

    func mostRecentCheck(for category: ProductCategory) -> ExpiryCheckRecord? {
        savedRecords
            .filter { $0.productCategory == category }
            .max { $0.checkedAt < $1.checkedAt }
    }
}

final class MockShiftRepository: ShiftRepository {
    private(set) var shifts: [Shift] = []

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
}

final class MockHandoverNoteRepository: HandoverNoteRepository {
    private(set) var savedNotes: [ShiftHandoverNote] = []

    func save(_ note: ShiftHandoverNote) {
        savedNotes.append(note)
    }

    func notes(forShiftID shiftID: UUID) -> [ShiftHandoverNote] {
        savedNotes.filter { $0.fromShiftID == shiftID }
    }

    func allNotes() -> [ShiftHandoverNote] {
        savedNotes
    }
}

final class LogExpiryCheckUseCaseTests: XCTestCase {
    private var checkRepository: MockExpiryCheckRepository!
    private var useCase: LogExpiryCheckUseCase!
    private let staff = StaffIdentifier(staffID: UUID(), name: "Jordan")
    private let shiftID = UUID()

    override func setUp() {
        super.setUp()
        checkRepository = MockExpiryCheckRepository()
        useCase = LogExpiryCheckUseCase(checkRepository: checkRepository)
    }

    func test_logExpiryCheck_succeeds_andClassifiesFreshStock_whenExpiryDateIsFarAway() throws {
        let farExpiryDate = Calendar.current.date(byAdding: .day, value: 30, to: Date())!

        let record = try useCase.execute(
            category: .dairy,
            shiftID: shiftID,
            checkedBy: staff,
            expiryDate: farExpiryDate
        )

        XCTAssertEqual(record.expiryStatus, .fresh)
        XCTAssertEqual(checkRepository.savedRecords.count, 1)
    }

    func test_logExpiryCheck_classifiesAsNearExpiry_atExactWarningWindowBoundary() throws {
        let checkedAt = Date()
        let boundaryExpiryDate = Calendar.current.date(byAdding: .day, value: 3, to: checkedAt)!

        let record = try useCase.execute(
            category: .drinks,
            shiftID: shiftID,
            checkedBy: staff,
            expiryDate: boundaryExpiryDate,
            checkedAt: checkedAt
        )

        XCTAssertEqual(record.expiryStatus, .nearExpiry)
    }

    func test_logExpiryCheck_classifiesAsExpired_whenExpiryDateIsInThePast() throws {
        let pastExpiryDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!

        let record = try useCase.execute(
            category: .chocolate,
            shiftID: shiftID,
            checkedBy: staff,
            expiryDate: pastExpiryDate
        )

        XCTAssertEqual(record.expiryStatus, .expired)
    }

    func test_logExpiryCheck_fails_whenCategoryAlreadyCheckedThisShift() throws {
        let expiryDate = Calendar.current.date(byAdding: .day, value: 10, to: Date())!
        try useCase.execute(category: .gum, shiftID: shiftID, checkedBy: staff, expiryDate: expiryDate)

        XCTAssertThrowsError(
            try useCase.execute(category: .gum, shiftID: shiftID, checkedBy: staff, expiryDate: expiryDate)
        ) { error in
            XCTAssertEqual(error as? ExpiryCheckError, .checkAlreadyLoggedToday(category: ProductCategory.gum.rawValue))
        }
    }
}
