//
//  HomeViewModel.swift
//  SoberGuy
//

import Observation

@Observable
final class HomeViewModel {
    private let coordinator: HomeCoordinator

    init(coordinator: HomeCoordinator) {
        self.coordinator = coordinator
    }

    func startJourneyTapped() {
        coordinator.showSetupPeople()
    }
}
