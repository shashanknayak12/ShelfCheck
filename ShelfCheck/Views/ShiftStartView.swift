//
//  ShiftStartView.swift
//  ShelfCheck
//
//  Created by Shashank Nayak on 13/9/2026.
//

import SwiftUI
 

struct ShiftStartView: View {
    @StateObject private var viewModel: ShiftStartViewModel
    @ObservedObject private var session: ShiftSession
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
        _session = ObservedObject(wrappedValue: viewModel.session)
        self.logExpiryCheckUseCase = logExpiryCheckUseCase
        self.reviewShiftComplianceUseCase = reviewShiftComplianceUseCase
        self.submitHandoverNoteUseCase = submitHandoverNoteUseCase
    }

    var body: some View {
        List {
            if session.currentStaff == nil {
                Section("Who's on shift?") {
                    ForEach(viewModel.availableStaff) { staff in
                        Button {
                            viewModel.selectStaff(staff)
                        } label: {
                            Label(staff.name, systemImage: "person.crop.circle.fill")
                        }
                    }
                }
            } else {
                Section("Today's progress") {
                    Label("Signed in as \(session.currentStaff?.name ?? "")", systemImage: "checkmark.seal.fill")
                        .font(.headline)
                        .foregroundStyle(.green)

                    ProgressView(
                        value: Double(viewModel.checkedCategories.count),
                        total: Double(ProductCategory.allCases.count)
                    )
                    Text("\(viewModel.checkedCategories.count) of \(ProductCategory.allCases.count) sections checked")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    ForEach(ProductCategory.allCases.filter { viewModel.outstandingCategories.contains($0) }) { category in
                        Label(category.rawValue, systemImage: category.iconName)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Actions") {
                    NavigationLink {
                        ChecklistView(viewModel: ChecklistViewModel(
                            logExpiryCheckUseCase: logExpiryCheckUseCase,
                            reviewShiftComplianceUseCase: reviewShiftComplianceUseCase,
                            session: session
                        ))
                    } label: {
                        Label("Open Checklist", systemImage: "checklist")
                    }

                    NavigationLink {
                        HandoverView(viewModel: HandoverViewModel(
                            submitHandoverNoteUseCase: submitHandoverNoteUseCase,
                            session: session
                        ))
                    } label: {
                        Label("Write Handover Note", systemImage: "square.and.pencil")
                    }

                    Button(role: .destructive) {
                        session.endShift()
                        viewModel.refreshIncomingNotes()
                    } label: {
                        Label("End Shift", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }

            if !viewModel.overdueWarnings.isEmpty {
                Section("Needs attention") {
                    ForEach(viewModel.overdueWarnings.map(\.localizedDescription), id: \.self) { message in
                        Label(message, systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                    }
                }
            }

            if !viewModel.incomingNotes.isEmpty {
                Section("Handover notes from last shift") {
                    ForEach(viewModel.incomingNotes) { note in
                        VStack(alignment: .leading, spacing: 4) {
                            Label(note.message, systemImage: "text.bubble.fill")
                            if let category = note.flaggedCategory {
                                Text(category.rawValue)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .padding(.leading, 24)
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Shift Start")
        .onAppear {
            viewModel.refreshTodaySummary()
        }
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
