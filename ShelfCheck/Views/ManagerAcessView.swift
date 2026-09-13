//
//  ManagerAcessView.swift
//  ShelfCheck
//
//  Created by Shashank Nayak on 14/9/2026.
//

import SwiftUI

/// Wraps any screen behind a shared code, used for the Manager tab so
/// casual staff don't wander into it by accident.
struct ManagerAccessView<Content: View>: View {
    @StateObject private var viewModel = ManagerAccessViewModel()
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        if viewModel.isUnlocked {
            content()
        } else {
            VStack(spacing: 16) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.blue)
                    .padding(.bottom, 4)

                Text("Manager Access")
                    .font(.title2.bold())
                Text("Enter the manager code to view shift compliance.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                SecureField("Code", text: $viewModel.enteredPIN)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                    .frame(maxWidth: 200)
                    .multilineTextAlignment(.center)

                Button {
                    viewModel.submitPIN()
                } label: {
                    Label("Unlock", systemImage: "lock.open.fill")
                        .frame(maxWidth: 200)
                }
                .buttonStyle(.borderedProminent)

                if viewModel.showIncorrectPINMessage {
                    Label("That code isn't right. Try again.", systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                        .font(.caption)
                }
            }
            .padding()
        }
    }
}

#Preview {
    ManagerAccessView {
        Text("Unlocked content goes here")
    }
}
