//
//  HandoverNoteRepository.swift
//  ShelfCheck
//
//  Created by Shashank Nayak on 12/9/2026.
//

import Foundation

/// here handover notes are stored and read back from  this is what
/// replaces the verbal handover between staff. SubmitHandoverNoteUseCase
/// writes to it , the Shift Start screen reads from it to show the incoming
/// notes left by the previous shift
protocol HandoverNoteRepository {
    func save(_ note: ShiftHandoverNote)
    func notes(forShiftID shiftID: UUID) -> [ShiftHandoverNote]
    func allNotes() -> [ShiftHandoverNote]
}
