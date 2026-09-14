//
//  ChecklistView.swift
//  ShelfCheck
//
//  Created by Shashank Nayak on 13/9/2026.
//

import SwiftUI

struct ChecklistView: View {
    @StateObject private var viewModel: ChecklistViewModel
    @State private var categoryPendingDate: ProductCategory?
    @State private var selectedExpiryDate = Date()
    @State private var itemNoteText = ""
    @State private var showScanUnavailable = false

    init(viewModel: ChecklistViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        List {
            Section("Today's Checklist") {
                ForEach(ProductCategory.allCases) { category in
                    let isChecked = viewModel.checkedCategories.contains(category)
                    Button {
                        selectedExpiryDate = Date()
                        itemNoteText = ""
                        categoryPendingDate = category
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: category.iconName)
                                .font(.body)
                                .foregroundStyle(isChecked ? .green : .blue)
                                .frame(width: 32, height: 32)
                                .background((isChecked ? Color.green : Color.blue).opacity(0.12))
                                .clipShape(Circle())

                            Text(category.rawValue)

                            Spacer()

                            if isChecked {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            } else {
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .disabled(isChecked)
                }
            }

            Section {
                Button {
                    showScanUnavailable = true
                } label: {
                    Label("Scan Item", systemImage: "barcode.viewfinder")
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Checklist")
        .sheet(item: $categoryPendingDate) { category in
            NavigationStack {
                Form {
                    DatePicker(
                        "Expiry date",
                        selection: $selectedExpiryDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)

                    Section("Item (optional)") {
                        TextField("e.g. Mars 46g", text: $itemNoteText)
                    }
                }
                .navigationTitle(category.rawValue)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            categoryPendingDate = nil
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Log Check") {
                            viewModel.logCheck(category: category, expiryDate: selectedExpiryDate, itemNote: itemNoteText)
                            categoryPendingDate = nil
                        }
                    }
                }
            }
            .presentationDetents([.medium, .large])
        }
        .alert("Couldn't log check", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .alert("Scan Item isn't set up yet", isPresented: $showScanUnavailable) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Log checks by section above for now.")
        }
    }
}

#Preview {
    let store = InMemoryShelfCheckStore()
    let session = ShiftSession(shiftRepository: store)
    session.startShift(for: store.allStaff().first!)
    let viewModel = ChecklistViewModel(
        logExpiryCheckUseCase: LogExpiryCheckUseCase(checkRepository: store),
        reviewShiftComplianceUseCase: ReviewShiftComplianceUseCase(checkRepository: store, shiftRepository: store),
        session: session
    )
    return NavigationStack {
        ChecklistView(viewModel: viewModel)
    }
}
