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
                HStack(spacing: 12) {
                    Image(systemName: slotIcon(for: report.shift.timeOfDaySlot))
                        .font(.title3)
                        .foregroundStyle(.blue)
                        .frame(width: 36, height: 36)
                        .background(Color.blue.opacity(0.12))
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(report.shift.timeOfDaySlot) shift")
                            .font(.headline)
                        Text(report.shift.staff.name)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    StatusBadge(status: report.status)
                }
                .padding(.vertical, 4)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Shift Status")
        .onAppear {
            viewModel.refresh()
        }
        .refreshable {
            viewModel.refresh()
        }
    }

    private func slotIcon(for slot: String) -> String {
        switch slot {
        case "Morning": return "sun.max.fill"
        case "Afternoon": return "sun.haze.fill"
        default: return "moon.stars.fill"
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
