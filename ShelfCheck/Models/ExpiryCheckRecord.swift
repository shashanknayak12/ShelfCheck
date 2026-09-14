//
//  ExpiryCheckRecord.swift
//  ShelfCheck
//
//  Created by Shashank Nayak on 11/9/2026.
//

import Foundation

/// One entry in the log is created every time a staff member checks a shelf
/// section for expired stock during a shift. This is what lets the next
/// shift see what is already been done instead of guessing or re checking.
///
/// Business rule is a category can only be logged once per shift (done by
/// LogExpiryCheckUseCase), which is why this record is tied to both a
/// shiftID and ProductCategory that pairing is what "already
/// checked" actually means.
struct ExpiryCheckRecord: Identifiable {
    let checkID: UUID
    let shiftID: UUID
    let productCategory: ProductCategory
    let checkedBy: StaffIdentifier
    let checkedAt: Date
    let expiryDate: Date
    let expiryStatus: ExpiryStatus
    let itemNote: String?

    var id: UUID { checkID }
}
