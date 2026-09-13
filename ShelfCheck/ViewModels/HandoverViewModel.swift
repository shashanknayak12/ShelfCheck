//
//  HandoverViewModel.swift
//  ShelfCheck
//
//  Created by Shashank Nayak on 13/9/2026.
//

import Foundation
import Combine

/// Drives the Handover screen. Submitting a note goes through
/// SubmitHandoverNoteUseCase, so the empty message and invalid shift rules
/// are always enforced no matter what the screen does.
final class HandoverViewModel: ObservableObject {
    @Published var message: String = ""
    @Published var flaggedCategory: ProductCategory?
    @Published var errorMessage: String?
    @Published var didSubmit = false

    private let submitHandoverNoteUseCase: SubmitHandoverNoteUseCase
    private let session: ShiftSession

    init(submitHandoverNoteUseCase: SubmitHandoverNoteUseCase, session: ShiftSession) {
        self.submitHandoverNoteUseCase = submitHandoverNoteUseCase
        self.session = session
    }

    func submit() {
        guard let shiftID = session.currentShift?.shiftID,
              let staff = session.currentStaff else { return }
        do {
            try submitHandoverNoteUseCase.execute(
                fromShiftID: shiftID,
                authoredBy: staff,
                message: message,
                flaggedCategory: flaggedCategory
            )
            message = ""
            flaggedCategory = nil
            errorMessage = nil
            didSubmit = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
