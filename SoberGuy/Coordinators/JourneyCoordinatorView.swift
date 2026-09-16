//
//  JourneyCoordinatorView.swift
//  SoberGuy
//

import SwiftUI

struct JourneyCoordinatorView: View {
    @State private var coordinator: JourneyCoordinator

    init(journey: Journey, persistenceService: PersistenceService, onClosed: @escaping () -> Void) {
        _coordinator = State(initialValue: JourneyCoordinator(
            journey: journey,
            persistenceService: persistenceService,
            onClosed: onClosed
        ))
    }

    var body: some View {
        @Bindable var coordinator = coordinator

        NavigationStack(path: $coordinator.path) {
            JourneyView(coordinator: coordinator)
                .navigationDestination(for: JourneyRoute.self) { route in
                    switch route {
                    case .summary:
                        SummaryView(coordinator: coordinator)
                    }
                }
                .sheet(item: $coordinator.sheetRoute) { route in
                    switch route {
                    case .addProduct:
                        NavigationStack { AddProductSheet(coordinator: coordinator) }
                    case .addPerson:
                        NavigationStack { AddPersonSheet(coordinator: coordinator) }
                    }
                }
        }
    }
}
