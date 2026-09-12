//
//  ShiftRepository.swift
//  ShelfCheck
//
//  Created by Shashank Nayak on 12/9/2026.
//

import Foundation

/// The record of every shift that happened at the store. Other Use Cases
/// check against this to confirm a shift actually exists before acting on
/// it  . example like  SubmitHandoverNoteUseCase looks up the shift ID on a note
/// here first, so a note can not be saved pointing at a shift that was never
/// real
protocol ShiftRepository {
    func shift(withID shiftID: UUID) -> Shift?
    func allShifts() -> [Shift]
    func save(_ shift: Shift)
}
