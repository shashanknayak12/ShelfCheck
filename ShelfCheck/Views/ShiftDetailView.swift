//
//  ShiftDetailView.swift
//  ShelfCheck
//
//  Created by Shashank Nayak on 14/9/2026.
//

import SwiftUI

struct ShiftDetailView: View {
    @StateObject private var viewModel: ShiftDetailViewModel

    init(viewModel: ShiftDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        List {
            Section("Shift") {
                LabeledContent("Staff", value: viewModel.report.shift.staff.name)
                LabeledContent("Slot", value: viewModel.report.shift.timeOfDaySlot)
                LabeledContent("Started", value: viewModel.report.shift.startedAt.formatted(date: .abbreviated, time: .shortened))
                if let endedAt = viewModel.report.shift.endedAt {
                    LabeledContent("Ended", value: endedAt.formatted(date: .abbreviated, time: .shortened))
                }
                statusRow
            }

            Section("Checked (\(viewModel.checks.count))") {
                if viewModel.checks.isEmpty {
                    Text("Nothing checked yet.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.checks) { check in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(check.productCategory.rawValue)
                            Text("\(check.expiryStatus.rawValue), \(check.checkedAt.formatted(date: .omitted, time: .shortened))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            if !viewModel.report.outstandingCategories.isEmpty {
                Section("Outstanding") {
                    ForEach(ProductCategory.allCases.filter { viewModel.report.outstandingCategories.contains($0) }) { category in
                        Text(category.rawValue)
                    }
                }
            }

            if !viewModel.notes.isEmpty {
                Section("Handover notes from this shift") {
                    ForEach(viewModel.notes) { note in
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
        .navigationTitle("\(viewModel.report.shift.timeOfDaySlot) Shift")
    }

    @ViewBuilder
    private var statusRow: some View {
        switch viewModel.report.status {
        case .complete:
            Label("Done", systemImage: "checkmark.circle.fill")
                .foregroundStyle(.green)
        case .inProgress:
            Label("In progress", systemImage: "clock.fill")
                .foregroundStyle(.orange)
        case .missed:
            Label("Missed", systemImage: "xmark.circle.fill")
                .foregroundStyle(.red)
        }
    }
}

#Preview {
    let store = InMemoryShelfCheckStore()
    let reviewShiftComplianceUseCase = ReviewShiftComplianceUseCase(checkRepository: store, shiftRepository: store)
    let report = reviewShiftComplianceUseCase.reviewAllShifts().first!
    let viewModel = ShiftDetailViewModel(report: report, checkRepository: store, noteRepository: store)
    return NavigationStack {
        ShiftDetailView(viewModel: viewModel)
    }
}
