//
//  ManagerDashboardModel.swift
//  ShelfCheck
//
//  Created by Shashank Nayak on 14/9/2026.
//

import Foundation
import Combine

///  the Manager Dashboard. Just reads from
/// ReviewShiftComplianceUseCase, since this screen only shows what is
/// already true about each shift, it doesn't change anything itself.
final class ManagerDashboardViewModel: ObservableObject {
    @Published private(set) var reports: [ShiftComplianceReport] = []

    private let reviewShiftComplianceUseCase: ReviewShiftComplianceUseCase

    init(reviewShiftComplianceUseCase: ReviewShiftComplianceUseCase) {
        self.reviewShiftComplianceUseCase = reviewShiftComplianceUseCase
        refresh()
    }

    func refresh() {
        reports = reviewShiftComplianceUseCase
            .reviewAllShifts()
            .sorted { $0.shift.startedAt > $1.shift.startedAt }
    }
}
