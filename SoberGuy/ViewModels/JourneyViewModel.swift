//
//  JourneyViewModel.swift
//  SoberGuy
//

import Observation

@Observable
final class JourneyViewModel {
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

    func addProductTapped() {
        coordinator.showAddProduct()
    }

    func addPersonTapped() {
        coordinator.showAddPerson()
    }

    func finishTapped() {
        coordinator.finish()
    }
}
