//
//  ShiftStartView.swift
//  ShelfCheck
//
//  Created by Shashank Nayak on 13/9/2026.
//

import SwiftUI
 
struct ShiftStartView: View {
    @StateObject private var viewModel: ShiftStartViewModel

    init(viewModel: ShiftStartViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
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
    let viewModel = ShiftStartViewModel(
        staffRepository: store,
        shiftRepository: store,
        noteRepository: store,
        logExpiryCheckUseCase: LogExpiryCheckUseCase(checkRepository: store),
        reviewShiftComplianceUseCase: ReviewShiftComplianceUseCase(checkRepository: store, shiftRepository: store),
        session: ShiftSession(shiftRepository: store)
    )
    return NavigationStack {
        ShiftStartView(viewModel: viewModel)
    }
}
