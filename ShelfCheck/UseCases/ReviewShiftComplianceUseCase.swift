//
//  ReviewShiftComplianceUseCase.swift
//  ShelfCheck
//
//  Created by Shashank Nayak on 12/9/2026.
//

import Foundation

/// Failure state for reviewing a shift that has not logged anything yet.
enum ComplianceReviewError: LocalizedError {
    case noDataForShift(shiftName: String)

    var errorDescription: String? {
        switch self {
        case .noDataForShift(let shiftName):
            return "No check records found for \(shiftName) shift yet."
        }
    }
}

/// Whether a shift finished what it was supposed to the same "done / in
/// progress / missed" status a manager would use walking past the roster.
enum ShiftComplianceStatus {
    case complete
    case inProgress
    case missed
}

/// The result of reviewing one shift  what got checked, what didn't, and
/// where that leaves the shift overall. This is what the Manager Dashboard
/// is actually built from
struct ShiftComplianceReport {
    let shift: Shift
    let checkedCategories: Set<ProductCategory>
    let outstandingCategories: Set<ProductCategory>
    let status: ShiftComplianceStatus
}

/// Reviews whether a shift completed its expiry checks.
///
/// Business rule  a shift only counts as "complete" once every product
/// category has been checked at least once checking 4 out of 5 sections
/// is not good enough, since the one you skipped is exactly the one that
/// might have expired stock on it. This is what lets a manager see, at a
/// glance, which shifts actually did the job
struct ReviewShiftComplianceUseCase {
    private let checkRepository: ExpiryCheckRepository
    private let shiftRepository: ShiftRepository

    init(checkRepository: ExpiryCheckRepository, shiftRepository: ShiftRepository) {
        self.checkRepository = checkRepository
        self.shiftRepository = shiftRepository
    }

    /// Reviews a single shift. Throws if the shift has logged no checks at
    /// all yet, rather than reporting every category as outstanding.
    func execute(shiftID: UUID) throws -> ShiftComplianceReport {
        guard let shift = shiftRepository.shift(withID: shiftID) else {
            throw ComplianceReviewError.noDataForShift(shiftName: "that")
        }

        let checksThisShift = checkRepository.checks(forShiftID: shiftID)
        guard !checksThisShift.isEmpty else {
            throw ComplianceReviewError.noDataForShift(shiftName: shift.timeOfDaySlot)
        }

        let checkedCategories = Set(checksThisShift.map(\.productCategory))
        let outstandingCategories = Set(ProductCategory.allCases).subtracting(checkedCategories)

        let status: ShiftComplianceStatus
        if outstandingCategories.isEmpty {
            status = .complete
        } else if shift.isActive {
            status = .inProgress
        } else {
            status = .missed
        }

        return ShiftComplianceReport(
            shift: shift,
            checkedCategories: checkedCategories,
            outstandingCategories: outstandingCategories,
            status: status
        )
    }

    /// Reviews every shift on record, for the Manager Dashboard's full
    /// overview. Unlike execute(shiftID), this does not throw for shifts
    /// with no checks yet it just reports them as missed or in progress,
    /// since a dashboard listing every shift can not skip the ones that
    /// haven't started checking 
    func reviewAllShifts() -> [ShiftComplianceReport] {
        shiftRepository.allShifts().map { shift in
            let checkedCategories = Set(
                checkRepository.checks(forShiftID: shift.shiftID).map(\.productCategory)
            )
            let outstandingCategories = Set(ProductCategory.allCases).subtracting(checkedCategories)

            let status: ShiftComplianceStatus
            if outstandingCategories.isEmpty {
                status = .complete
            } else if shift.isActive {
                status = .inProgress
            } else {
                status = .missed
            }

            return ShiftComplianceReport(
                shift: shift,
                checkedCategories: checkedCategories,
                outstandingCategories: outstandingCategories,
                status: status
            )
        }
    }
}
