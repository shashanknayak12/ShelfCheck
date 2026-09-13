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
                HStack {
                    Text("Status")
                    Spacer()
                    StatusBadge(status: viewModel.report.status)
                }
            }

            Section("Checked (\(viewModel.checks.count))") {
                if viewModel.checks.isEmpty {
                    Text("Nothing checked yet.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.checks) { check in
                        HStack(spacing: 12) {
                            Image(systemName: check.expiryStatus.iconName)
                                .foregroundStyle(check.expiryStatus.tintColor)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(check.productCategory.rawValue)
                                Text("\(check.expiryStatus.rawValue) · \(check.checkedAt.formatted(date: .omitted, time: .shortened))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }

            if !viewModel.report.outstandingCategories.isEmpty {
                Section("Outstanding") {
                    ForEach(ProductCategory.allCases.filter { viewModel.report.outstandingCategories.contains($0) }) { category in
                        Label(category.rawValue, systemImage: category.iconName)
                            .foregroundStyle(.secondary)
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
