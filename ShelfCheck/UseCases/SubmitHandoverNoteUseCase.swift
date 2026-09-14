//
//  SubmitHandoverNoteUseCase.swift
//  ShelfCheck
//
//  Created by Shashank Nayak on 12/9/2026.
//

import Foundation

/// Failure states for submitting a handover note, written for the staff
/// member writing it
enum HandoverNoteError: LocalizedError, Equatable {
    case emptyNoteMessage
    case invalidShiftReference

    var errorDescription: String? {
        switch self {
        case .emptyNoteMessage:
            return "Handover note can't be empty. Add a short message for the next shift."
        case .invalidShiftReference:
            return "Couldn't find the next shift to send this note to. Try again or contact your manager."
        }
    }
}

/// Submits a note from one shift to the next  the digital version of
/// writing something in the paper log or telling the next person verbally
/// on the way out.
///
/// Business rule is a note must have an actual message (no blank notes taking
/// up space in the handover list) and must be tied to a real shift, so it
/// always has somewhere to actually go
struct SubmitHandoverNoteUseCase {
    private let noteRepository: HandoverNoteRepository
    private let shiftRepository: ShiftRepository

    init(noteRepository: HandoverNoteRepository, shiftRepository: ShiftRepository) {
        self.noteRepository = noteRepository
        self.shiftRepository = shiftRepository
    }

    @discardableResult
    func execute(
        fromShiftID: UUID,
        authoredBy: StaffIdentifier,
        message: String,
        flaggedCategory: ProductCategory?,
        createdAt: Date = Date()
    ) throws -> ShiftHandoverNote {
        let trimmedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else {
            throw HandoverNoteError.emptyNoteMessage
        }

        guard shiftRepository.shift(withID: fromShiftID) != nil else {
            throw HandoverNoteError.invalidShiftReference
        }

        let note = ShiftHandoverNote(
            noteID: UUID(),
            fromShiftID: fromShiftID,
            authoredBy: authoredBy,
            message: trimmedMessage,
            flaggedCategory: flaggedCategory,
            createdAt: createdAt
        )
        noteRepository.save(note)
        return note
    }
}
