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
                ZStack(alignment: .topLeading) {
                    if viewModel.message.isEmpty {
                        Text("e.g. \"Didn't get to gum section, please check first thing\"")
                            .foregroundStyle(.tertiary)
                            .padding(.top, 8)
                            .padding(.leading, 4)
                    }
                    TextEditor(text: $viewModel.message)
                        .frame(minHeight: 100)
                }
            }

            Section("Flag a section (optional)") {
                Picker(selection: $viewModel.flaggedCategory) {
                    Text("None").tag(ProductCategory?.none)
                    ForEach(ProductCategory.allCases) { category in
                        Label(category.rawValue, systemImage: category.iconName)
                            .tag(ProductCategory?.some(category))
                    }
                } label: {
                    Label("Section", systemImage: "tag.fill")
                }
            }

            Section {
                Button {
                    viewModel.submit()
                } label: {
                    Label("Send to Next Shift", systemImage: "paperplane.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .listRowBackground(Color.clear)
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
