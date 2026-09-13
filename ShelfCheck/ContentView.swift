//
//  ContentView.swift
//  ShelfCheck
//
//  Created by Shashank Nayak on 11/9/2026.
//

import SwiftUI

struct ContentView: View {
    let store: InMemoryShelfCheckStore
    @ObservedObject var session: ShiftSession

    private var logExpiryCheckUseCase: LogExpiryCheckUseCase {
        LogExpiryCheckUseCase(checkRepository: store)
    }

    private var reviewShiftComplianceUseCase: ReviewShiftComplianceUseCase {
        ReviewShiftComplianceUseCase(checkRepository: store, shiftRepository: store)
    }

    private var submitHandoverNoteUseCase: SubmitHandoverNoteUseCase {
        SubmitHandoverNoteUseCase(noteRepository: store, shiftRepository: store)
    }

    var body: some View {
        TabView {
            NavigationStack {
                ShiftStartView(
                    viewModel: ShiftStartViewModel(
                        staffRepository: store,
                        shiftRepository: store,
                        noteRepository: store,
                        logExpiryCheckUseCase: logExpiryCheckUseCase,
                        reviewShiftComplianceUseCase: reviewShiftComplianceUseCase,
                        session: session
                    ),
                    logExpiryCheckUseCase: logExpiryCheckUseCase,
                    reviewShiftComplianceUseCase: reviewShiftComplianceUseCase,
                    submitHandoverNoteUseCase: submitHandoverNoteUseCase
                )
            }
            .tabItem {
                Label("My Shift", systemImage: "checklist")
            }

            NavigationStack {
                ManagerAccessView {
                    ManagerDashboardView(
                        viewModel: ManagerDashboardViewModel(
                            reviewShiftComplianceUseCase: reviewShiftComplianceUseCase
                        ),
                        checkRepository: store,
                        noteRepository: store
                    )
                }
            }
            .tabItem {
                Label("Manager", systemImage: "chart.bar")
            }
        }
    }
}

#Preview {
    let store = InMemoryShelfCheckStore()
    return ContentView(store: store, session: ShiftSession(shiftRepository: store))
}
