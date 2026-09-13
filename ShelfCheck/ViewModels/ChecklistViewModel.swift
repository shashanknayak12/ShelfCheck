//
//  ChecklistViewModel.swift
//  ShelfCheck
//
//  Created by Shashank Nayak on 13/9/2026.
//

import Foundation
import Combine

/// the Checklist screen. Logging a check goes through
/// LogExpiryCheckUseCase, so the "already checked this shift" rule is
/// always enforced no matter what the screen shows. Knowing which
/// categories are already done for this shift reuses
/// ReviewShiftComplianceUseCase's report rather than duplicating that logic
/// here.
final class ChecklistViewModel: ObservableObject {
    @Published private(set) var checkedCategories: Set<ProductCategory> = []
    @Published var errorMessage: String?

    private let logExpiryCheckUseCase: LogExpiryCheckUseCase
    private let reviewShiftComplianceUseCase: ReviewShiftComplianceUseCase
    private let session: ShiftSession

    init(
        logExpiryCheckUseCase: LogExpiryCheckUseCase,
        reviewShiftComplianceUseCase: ReviewShiftComplianceUseCase,
        session: ShiftSession
    ) {
        self.logExpiryCheckUseCase = logExpiryCheckUseCase
        self.reviewShiftComplianceUseCase = reviewShiftComplianceUseCase
        self.session = session
        refreshCheckedCategories()
    }

    /// Logs a check for a category. If it is already been checked this
    /// shift, the Use Case throws instead of silently duplicating it, and
    /// that message gets surfaced to the person tapping the button.
    func logCheck(category: ProductCategory, status: ExpiryStatus) {
        guard let shiftID = session.currentShift?.shiftID,
              let staff = session.currentStaff else { return }
        do {
            try logExpiryCheckUseCase.execute(
                category: category,
                shiftID: shiftID,
                checkedBy: staff,
                expiryStatus: status
            )
            refreshCheckedCategories()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func refreshCheckedCategories() {
        guard let shiftID = session.currentShift?.shiftID else { return }
        do {
            let report = try reviewShiftComplianceUseCase.execute(shiftID: shiftID)
            checkedCategories = report.checkedCategories
        } catch {
            checkedCategories = []
        }
    }
}
