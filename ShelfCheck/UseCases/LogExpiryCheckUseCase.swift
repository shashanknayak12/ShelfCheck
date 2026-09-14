//
//  LogExpiryCheckUseCase.swift
//  ShelfCheck
//
//  Created by Shashank Nayak on 12/9/2026.
//

import Foundation

/// Failure states for logging an expiry check, written for the staff member

enum ExpiryCheckError: LocalizedError, Equatable {
    case checkAlreadyLoggedToday(category: String)
    case categoryOverdue(category: String, hoursOverdue: Int)

    var errorDescription: String? {
        switch self {
        case .checkAlreadyLoggedToday(let category):
            return "\(category) was already checked this shift. No action needed."
        case .categoryOverdue(let category, let hours):
            return "\(category) check is \(hours) hours overdue. Check now before serving customers."
        }
    }
}

/// Logs a staff member expiry check of one shelf section during a shift.
///
/// Business rule is a category can not be checked twice in the same shift ,iif
/// it is already been done, the next person to try gets told so instead of
/// silently duplicating the record. This is also how the app knows which
/// categories have gone unchecked for too long, so it can flag them before
/// stock actually goes out of date on the shelf
struct LogExpiryCheckUseCase {
    private let checkRepository: ExpiryCheckRepository
    private let overdueThresholdHours: Int
    private let nearExpiryWarningDays: Int

    init(
        checkRepository: ExpiryCheckRepository,
        overdueThresholdHours: Int = 24,
        nearExpiryWarningDays: Int = 3
    ) {
        self.checkRepository = checkRepository
        self.overdueThresholdHours = overdueThresholdHours
        self.nearExpiryWarningDays = nearExpiryWarningDays
    }

    @discardableResult
    func execute(
        category: ProductCategory,
        shiftID: UUID,
        checkedBy: StaffIdentifier,
        expiryDate: Date,
        itemNote: String? = nil,
        checkedAt: Date = Date()
    ) throws -> ExpiryCheckRecord {
        let alreadyLoggedThisShift = checkRepository
            .checks(forShiftID: shiftID)
            .contains { $0.productCategory == category }

        guard !alreadyLoggedThisShift else {
            throw ExpiryCheckError.checkAlreadyLoggedToday(category: category.rawValue)
        }

        let trimmedNote = itemNote?.trimmingCharacters(in: .whitespacesAndNewlines)

        let record = ExpiryCheckRecord(
            checkID: UUID(),
            shiftID: shiftID,
            productCategory: category,
            checkedBy: checkedBy,
            checkedAt: checkedAt,
            expiryDate: expiryDate,
            expiryStatus: classifyExpiryStatus(expiryDate: expiryDate, asOf: checkedAt),
            itemNote: (trimmedNote?.isEmpty ?? true) ? nil : trimmedNote
        )
        checkRepository.save(record)
        return record
    }

    /// Works out fresh vs near expiry vs expired straight from the date
    /// printed on the product, rather than leaving it to staff to eyeball.
    /// This is the actual business rule behind what counts as "near
    /// expiry" anything due within nearExpiryWarningDays.
    private func classifyExpiryStatus(expiryDate: Date, asOf now: Date) -> ExpiryStatus {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: now)
        let startOfExpiry = calendar.startOfDay(for: expiryDate)

        if startOfExpiry < startOfToday {
            return .expired
        }

        let daysUntilExpiry = calendar.dateComponents([.day], from: startOfToday, to: startOfExpiry).day ?? 0
        return daysUntilExpiry <= nearExpiryWarningDays ? .nearExpiry : .fresh
    }

    /// Categories that have not been checked within the overdue window,
    /// based on their most recent check ever logged not only in this shift
    /// Used to surface warnings on the Shift Start summary  this does not
    /// block anything, it just flags what needs attention.
    func overdueCategories(asOf now: Date = Date()) -> [ExpiryCheckError] {
        ProductCategory.allCases.compactMap { category in
            guard let lastChecked = checkRepository.mostRecentCheck(for: category)?.checkedAt else {
                return nil
            }
            let hoursSince = Int(now.timeIntervalSince(lastChecked) / 3600)
            guard hoursSince > overdueThresholdHours else { return nil }
            return .categoryOverdue(category: category.rawValue, hoursOverdue: hoursSince)
        }
    }
}
