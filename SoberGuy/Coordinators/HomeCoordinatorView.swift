//
//  HomeCoordinatorView.swift
//  SoberGuy
//

import SwiftUI

struct HomeCoordinatorView: View {
    @State private var coordinator: HomeCoordinator

    init(persistenceService: PersistenceService, onJourneyStarted: @escaping (Journey) -> Void) {
        _coordinator = State(initialValue: HomeCoordinator(
            persistenceService: persistenceService,
            onJourneyStarted: onJourneyStarted
        ))
    }

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            HomeView(coordinator: coordinator)
                .navigationDestination(for: HomeRoute.self) { route in
                    switch route {
                    case .setupPeople:
                        SetupPeopleView(coordinator: coordinator)
                    }
                }
        }
    }
}
