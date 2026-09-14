//
//  SubmitHandoverNoteUseCaseTests.swift
//  ShelfCheckTests
//
//  Created by Shashank Nayak on 14/9/2026.
//

import XCTest
@testable import ShelfCheck

final class SubmitHandoverNoteUseCaseTests: XCTestCase {
    private var noteRepository: MockHandoverNoteRepository!
    private var shiftRepository: MockShiftRepository!
    private var useCase: SubmitHandoverNoteUseCase!
    private let staff = StaffIdentifier(staffID: UUID(), name: "Jordan")
    private var shift: Shift!

    override func setUp() {
        super.setUp()
        noteRepository = MockHandoverNoteRepository()
        shiftRepository = MockShiftRepository()
        useCase = SubmitHandoverNoteUseCase(noteRepository: noteRepository, shiftRepository: shiftRepository)

        shift = Shift(shiftID: UUID(), staff: staff, startedAt: Date(), endedAt: nil)
        shiftRepository.save(shift)
    }

    func test_submitHandoverNote_succeeds_withValidMessageAndShift() throws {
        let note = try useCase.execute(
            fromShiftID: shift.shiftID,
            authoredBy: staff,
            message: "Gum section still needs checking.",
            flaggedCategory: .gum
        )

        XCTAssertEqual(note.message, "Gum section still needs checking.")
        XCTAssertEqual(note.flaggedCategory, .gum)
        XCTAssertEqual(noteRepository.savedNotes.count, 1)
    }

    func test_submitHandoverNote_fails_whenMessageIsEmpty() {
        XCTAssertThrowsError(
            try useCase.execute(
                fromShiftID: shift.shiftID,
                authoredBy: staff,
                message: "",
                flaggedCategory: nil
            )
        ) { error in
            XCTAssertEqual(error as? HandoverNoteError, .emptyNoteMessage)
        }
    }

    /// Boundary case: the message isn't literally empty, but trims down to
    /// nothing, whitespace-only input should be treated the same as empty.
    func test_submitHandoverNote_fails_whenMessageIsOnlyWhitespace() {
        XCTAssertThrowsError(
            try useCase.execute(
                fromShiftID: shift.shiftID,
                authoredBy: staff,
                message: "   \n  ",
                flaggedCategory: nil
            )
        ) { error in
            XCTAssertEqual(error as? HandoverNoteError, .emptyNoteMessage)
        }
    }

    func test_submitHandoverNote_fails_whenShiftDoesNotExist() {
        let unknownShiftID = UUID()

        XCTAssertThrowsError(
            try useCase.execute(
                fromShiftID: unknownShiftID,
                authoredBy: staff,
                message: "Check the drinks fridge.",
                flaggedCategory: .drinks
            )
        ) { error in
            XCTAssertEqual(error as? HandoverNoteError, .invalidShiftReference)
        }
    }
}
