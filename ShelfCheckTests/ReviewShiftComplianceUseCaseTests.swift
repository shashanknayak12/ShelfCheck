//
//  ReviewShiftComplianceUseCaseTests.swift
//  ShelfCheckTests
//
//  Created by Shashank Nayak on 14/9/2026.
//

import XCTest
@testable import ShelfCheck

final class ReviewShiftComplianceUseCaseTests: XCTestCase {
    private var checkRepository: MockExpiryCheckRepository!
    private var shiftRepository: MockShiftRepository!
    private var useCase: ReviewShiftComplianceUseCase!
    private let staff = StaffIdentifier(staffID: UUID(), name: "Jordan")

    override func setUp() {
        super.setUp()
        checkRepository = MockExpiryCheckRepository()
        shiftRepository = MockShiftRepository()
        useCase = ReviewShiftComplianceUseCase(checkRepository: checkRepository, shiftRepository: shiftRepository)
    }

    private func logCheck(category: ProductCategory, shiftID: UUID) {
        checkRepository.save(
            ExpiryCheckRecord(
                checkID: UUID(),
                shiftID: shiftID,
                productCategory: category,
                checkedBy: staff,
                checkedAt: Date(),
                expiryDate: Date(),
                expiryStatus: .fresh,
                itemNote: nil
            )
        )
    }

    func test_reviewShiftCompliance_reportsComplete_whenAllCategoriesChecked() throws {
        let shift = Shift(shiftID: UUID(), staff: staff, startedAt: Date(), endedAt: nil)
        shiftRepository.save(shift)
        for category in ProductCategory.allCases {
            logCheck(category: category, shiftID: shift.shiftID)
        }

        let report = try useCase.execute(shiftID: shift.shiftID)

        XCTAssertEqual(report.status, .complete)
        XCTAssertTrue(report.outstandingCategories.isEmpty)
    }

    /// Boundary: a shift tha is still active (not ended yet) with some
    /// categories left should read as "in progress," not "missed" - the
    /// same outstanding count means something different depending on
    /// whether the shift is still running.
    func test_reviewShiftCompliance_reportsInProgress_whenActiveShiftHasOutstandingCategories() throws {
        let shift = Shift(shiftID: UUID(), staff: staff, startedAt: Date(), endedAt: nil)
        shiftRepository.save(shift)
        logCheck(category: .dairy, shiftID: shift.shiftID)

        let report = try useCase.execute(shiftID: shift.shiftID)

        XCTAssertEqual(report.status, .inProgress)
        XCTAssertEqual(report.outstandingCategories.count, ProductCategory.allCases.count - 1)
    }

    func test_reviewShiftCompliance_reportsMissed_whenEndedShiftHasOutstandingCategories() throws {
        let shift = Shift(shiftID: UUID(), staff: staff, startedAt: Date(), endedAt: Date())
        shiftRepository.save(shift)
        logCheck(category: .dairy, shiftID: shift.shiftID)

        let report = try useCase.execute(shiftID: shift.shiftID)

        XCTAssertEqual(report.status, .missed)
    }

    func test_reviewShiftCompliance_fails_whenNoChecksLoggedForShift() {
        let shift = Shift(shiftID: UUID(), staff: staff, startedAt: Date(), endedAt: nil)
        shiftRepository.save(shift)

        XCTAssertThrowsError(try useCase.execute(shiftID: shift.shiftID)) { error in
            guard case ComplianceReviewError.noDataForShift = error else {
                XCTFail("Expected noDataForShift, got \(error)")
                return
            }
        }
    }

    func test_reviewShiftCompliance_fails_whenShiftDoesNotExist() {
        XCTAssertThrowsError(try useCase.execute(shiftID: UUID())) { error in
            guard case ComplianceReviewError.noDataForShift = error else {
                XCTFail("Expected noDataForShift, got \(error)")
                return
            }
        }
    }
}
