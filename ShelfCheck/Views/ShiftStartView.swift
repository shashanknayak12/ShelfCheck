//
//  ShiftStartView.swift
//  ShelfCheck
//
//  Created by Shashank Nayak on 13/9/2026.
//

import SwiftUI
 

struct ShiftStartView: View {
    @StateObject private var viewModel: ShiftStartViewModel
    let logExpiryCheckUseCase: LogExpiryCheckUseCase
    let reviewShiftComplianceUseCase: ReviewShiftComplianceUseCase
    let submitHandoverNoteUseCase: SubmitHandoverNoteUseCase

    init(
        viewModel: ShiftStartViewModel,
        logExpiryCheckUseCase: LogExpiryCheckUseCase,
        reviewShiftComplianceUseCase: ReviewShiftComplianceUseCase,
        submitHandoverNoteUseCase: SubmitHandoverNoteUseCase
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.logExpiryCheckUseCase = logExpiryCheckUseCase
        self.reviewShiftComplianceUseCase = reviewShiftComplianceUseCase
        self.submitHandoverNoteUseCase = submitHandoverNoteUseCase
    }

    var body: some View {
        List {
            if viewModel.session.currentStaff == nil {
                Section("Who's on shift?") {
                    ForEach(viewModel.availableStaff) { staff in
                        Button(staff.name) {
                            viewModel.selectStaff(staff)
                        }
                    }
                }
            } else {
                Section("Today's progress") {
                    Text("Signed in as \(viewModel.session.currentStaff?.name ?? "")")
                        .font(.headline)
                    Text("\(viewModel.checkedCategories.count) of \(ProductCategory.allCases.count) sections checked")
                        .foregroundStyle(.secondary)

                    ForEach(ProductCategory.allCases.filter { viewModel.outstandingCategories.contains($0) }) { category in
                        Label(category.rawValue, systemImage: "circle")
                    }
                }

                Section("Actions") {
                    NavigationLink("Open Checklist") {
                        ChecklistView(viewModel: ChecklistViewModel(
                            logExpiryCheckUseCase: logExpiryCheckUseCase,
                            reviewShiftComplianceUseCase: reviewShiftComplianceUseCase,
                            session: viewModel.session
                        ))
                    }

                    NavigationLink("Write Handover Note") {
                        HandoverView(viewModel: HandoverViewModel(
                            submitHandoverNoteUseCase: submitHandoverNoteUseCase,
                            session: viewModel.session
                        ))
                    }
                }
            }

            if !viewModel.overdueWarnings.isEmpty {
                Section("Needs attention") {
                    ForEach(viewModel.overdueWarnings.map(\.localizedDescription), id: \.self) { message in
                        Text(message)
                            .foregroundStyle(.red)
                    }
                }
            }

            if !viewModel.incomingNotes.isEmpty {
                Section("Handover notes from last shift") {
                    ForEach(viewModel.incomingNotes) { note in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(note.message)
                            if let category = note.flaggedCategory {
                                Text(category.rawValue)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Shift Start")
    }
}

#Preview {
    let store = InMemoryShelfCheckStore()
    let logExpiryCheckUseCase = LogExpiryCheckUseCase(checkRepository: store)
    let reviewShiftComplianceUseCase = ReviewShiftComplianceUseCase(checkRepository: store, shiftRepository: store)
    let submitHandoverNoteUseCase = SubmitHandoverNoteUseCase(noteRepository: store, shiftRepository: store)
    let viewModel = ShiftStartViewModel(
        staffRepository: store,
        shiftRepository: store,
        noteRepository: store,
        logExpiryCheckUseCase: logExpiryCheckUseCase,
        reviewShiftComplianceUseCase: reviewShiftComplianceUseCase,
        session: ShiftSession(shiftRepository: store)
    )
    return NavigationStack {
        ShiftStartView(
            viewModel: viewModel,
            logExpiryCheckUseCase: logExpiryCheckUseCase,
            reviewShiftComplianceUseCase: reviewShiftComplianceUseCase,
            submitHandoverNoteUseCase: submitHandoverNoteUseCase
        )
    }
}
