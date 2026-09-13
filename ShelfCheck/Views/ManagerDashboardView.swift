//
//  ManagerDashboardView.swift
//  ShelfCheck
//
//  Created by Shashank Nayak on 14/9/2026.
//

import SwiftUI

struct ManagerDashboardView: View {
    @StateObject private var viewModel: ManagerDashboardViewModel
    let checkRepository: ExpiryCheckRepository
    let noteRepository: HandoverNoteRepository

    init(
        viewModel: ManagerDashboardViewModel,
        checkRepository: ExpiryCheckRepository,
        noteRepository: HandoverNoteRepository
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.checkRepository = checkRepository
        self.noteRepository = noteRepository
    }

    var body: some View {
        List(viewModel.reports, id: \.shift.shiftID) { report in
            NavigationLink {
                ShiftDetailView(viewModel: ShiftDetailViewModel(
                    report: report,
                    checkRepository: checkRepository,
                    noteRepository: noteRepository
                ))
            } label: {
                HStack {
                    VStack(alignment: .leading) {
                        Text("\(report.shift.timeOfDaySlot) shift")
                            .font(.headline)
                        Text(report.shift.staff.name)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    statusLabel(for: report.status)
                }
            }
        }
        .navigationTitle("Shift Status")
        .onAppear {
            viewModel.refresh()
        }
        .refreshable {
            viewModel.refresh()
        }
    }

    @ViewBuilder
    private func statusLabel(for status: ShiftComplianceStatus) -> some View {
        switch status {
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
    let viewModel = ManagerDashboardViewModel(
        reviewShiftComplianceUseCase: ReviewShiftComplianceUseCase(checkRepository: store, shiftRepository: store)
    )
    return NavigationStack {
        ManagerDashboardView(viewModel: viewModel, checkRepository: store, noteRepository: store)
    }
}
