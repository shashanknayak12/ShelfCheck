//
//  ShelfCheckApp.swift
//  ShelfCheck
//
//  Created by Shashank Nayak on 11/9/2026.
//

import SwiftUI

@main
struct ShelfCheckApp: App {
    private let store: InMemoryShelfCheckStore
    @StateObject private var session: ShiftSession

    init() {
        let store = InMemoryShelfCheckStore()
        self.store = store
        _session = StateObject(wrappedValue: ShiftSession(shiftRepository: store))
    }

    var body: some Scene {
        WindowGroup {
            ContentView(store: store, session: session)
        }
    }
}
