//
//  ProductCategory.swift
//  ShelfCheck
//
//  Created by Shashank Nayak on 11/9/2026.
//

import Foundation

/// The shelf sections staff are expected to check for expired stock.
///
/// This is the actual list from walking the store floor dairy fridge, hot
/// food, drinks fridge, chocolate, and gum. Every check, handover note, and
/// compliance review is scoped to one of these, since "checked" only means
/// something once you say which section.
enum ProductCategory: String, CaseIterable, Identifiable {
    case dairy = "Dairy fridge"
    case hotFood = "Hot food"
    case drinks = "Drinks fridge"
    case chocolate = "Chocolate section"
    case gum = "Gum section"

    var id: String { rawValue }
}
