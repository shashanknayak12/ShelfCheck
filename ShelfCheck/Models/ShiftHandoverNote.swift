//
//  ShiftHandoverNote.swift
//  ShelfCheck
//
//  Created by Shashank Nayak on 11/9/2026.
//

import Foundation

/// A note one shift leaves for whoever is working next like "eggs expire
/// today, check before you go." This is what replaces the verbal handover
/// or the paper log staff currently rely on, which is easy to forget or
/// lose between shifts
///
/// Business rule: enforced by SubmitHandoverNoteUsecse , the message
/// can not  be empty and fromShiftID must point to a real shift, since a
/// note that isn't tied to an actual shift has nowhere to be handed to
struct ShiftHandoverNote: Identifiable {
    let noteID: UUID
    let fromShiftID: UUID
    let authoredBy: StaffIdentifier
    let message: String
    let flaggedCategory: ProductCategory?
    let createdAt: Date

    var id: UUID { noteID }
}
