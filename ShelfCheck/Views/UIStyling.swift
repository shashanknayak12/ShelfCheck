//
//  UIStyling.swift
//  ShelfCheck
//
//  Created by Shashank Nayak on 14/9/2026.
//

import SwiftUI

/// Shared icons and colors for domain types, so every screen shows a
/// category or a status the same way instead of each screen picking its
/// own. Pure presentation, the domain models themselves stay untouched.

extension ProductCategory {
    var iconName: String {
        switch self {
        case .dairy: return "refrigerator.fill"
        case .hotFood: return "flame.fill"
        case .drinks: return "cup.and.saucer.fill"
        case .chocolate: return "square.grid.2x2.fill"
        case .gum: return "circle.grid.2x2.fill"
        }
    }
}

extension ExpiryStatus {
    var tintColor: Color {
        switch self {
        case .fresh: return .green
        case .nearExpiry: return .orange
        case .expired: return .red
        }
    }

    var iconName: String {
        switch self {
        case .fresh: return "checkmark.circle.fill"
        case .nearExpiry: return "exclamationmark.triangle.fill"
        case .expired: return "xmark.octagon.fill"
        }
    }
}

extension ShiftComplianceStatus {
    var label: String {
        switch self {
        case .complete: return "Done"
        case .inProgress: return "In progress"
        case .missed: return "Missed"
        }
    }

    var iconName: String {
        switch self {
        case .complete: return "checkmark.circle.fill"
        case .inProgress: return "clock.fill"
        case .missed: return "xmark.circle.fill"
        }
    }

    var tintColor: Color {
        switch self {
        case .complete: return .green
        case .inProgress: return .orange
        case .missed: return .red
        }
    }
}

extension ExpiryCheckRecord {
    /// A short line describing when this item expires, worded differently
   
    var expiryDateSummary: String {
        let dateText = expiryDate.formatted(date: .abbreviated, time: .omitted)
        switch expiryStatus {
        case .expired: return "Expired on \(dateText)"
        case .nearExpiry: return "Will expire on \(dateText)"
        case .fresh: return "Expires on \(dateText)"
        }
    }
}

/// A small colored pill used to show a status at a glance, e.g. "Done" in
/// green or "Missed" in red, reused on the Manager Dashboard and the
/// shift detail screen.
struct StatusBadge: View {
    let status: ShiftComplianceStatus

    var body: some View {
        Label(status.label, systemImage: status.iconName)
            .font(.caption.bold())
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(status.tintColor.opacity(0.15))
            .foregroundStyle(status.tintColor)
            .clipShape(Capsule())
    }
}
