//
//  HandoverView.swift
//  ShelfCheck
//
//  Created by Shashank Nayak on 13/9/2026.
//

import SwiftUI

struct HandoverView: View {
    @StateObject private var viewModel: HandoverViewModel

    init(viewModel: HandoverViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Form {
            Section("Handover Note") {
                TextEditor(text: $viewModel.message)
                    .frame(minHeight: 100)
            }

            Section("Flag a section (optional)") {
                Picker("Section", selection: $viewModel.flaggedCategory) {
                    Text("None").tag(ProductCategory?.none)
                    ForEach(ProductCategory.allCases) { category in
                        Text(category.rawValue).tag(ProductCategory?.some(category))
                    }
                }
            }

            Section {
                Button("Send to Next Shift") {
                    viewModel.submit()
                }
            }
        }
        .navigationTitle("Handover")
        .alert("Couldn't send note", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .alert("Note sent to next shift", isPresented: $viewModel.didSubmit) {
            Button("OK", role: .cancel) {}
        }
    }
}

#Preview {
    let store = InMemoryShelfCheckStore()
    let session = ShiftSession(shiftRepository: store)
    session.startShift(for: store.allStaff().first!)
    let viewModel = HandoverViewModel(
        submitHandoverNoteUseCase: SubmitHandoverNoteUseCase(noteRepository: store, shiftRepository: store),
        session: session
    )
    return NavigationStack {
        HandoverView(viewModel: viewModel)
    }
}
