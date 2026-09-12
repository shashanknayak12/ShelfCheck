//
//  ExpiryCheckRepository.swift
//  ShelfCheck
//
//  Created by Shashank Nayak on 12/9/2026.
//

import Foundation

/// The shared log of expiry checks , this is the digital replacement for
/// the paper log, the single source of truth every shift reads from and
/// writes to. LogExpiryCheckUseCase and ReviewShiftComplianceUseCase
/// both depend on this rather than caring how the data is actually stored
protocol ExpiryCheckRepository {
    func save(_ record: ExpiryCheckRecord)
    func checks(forShiftID shiftID: UUID) -> [ExpiryCheckRecord]
    func mostRecentCheck(for category: ProductCategory) -> ExpiryCheckRecord?
}
