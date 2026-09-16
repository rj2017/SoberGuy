//
//  SummaryViewModel.swift
//  SoberGuy
//

import Observation

@Observable
final class SummaryViewModel {
    private let coordinator: JourneyCoordinator

    init(coordinator: JourneyCoordinator) {
        self.coordinator = coordinator
    }

    var people: [Person] {
        coordinator.journey.people
    }

    func formattedTotal(for person: Person) -> String {
        CurrencyFormatter.string(from: coordinator.journey.total(for: person))
    }

    func closeTapped() {
        coordinator.closeSummary()
    }
}
