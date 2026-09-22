//
//  JourneyViewModel.swift
//  SoberGuy
//

import Foundation
import Observation

struct PersonRemovalInfo: Identifiable {
    let id = UUID()
    let personName: String
    let amount: Decimal
}

@Observable
final class JourneyViewModel {
    private let coordinator: JourneyCoordinator
    var removalInfo: PersonRemovalInfo?

    init(coordinator: JourneyCoordinator) {
        self.coordinator = coordinator
    }

    var people: [Person] {
        coordinator.journey.people
    }

    func formattedTotal(for person: Person) -> String {
        CurrencyFormatter.string(from: coordinator.journey.total(for: person))
    }

    /// Regra: não é permitido remover uma pessoa se houver apenas 1 na jornada.
    var canRemovePeople: Bool {
        coordinator.journey.people.count > 1
    }

    func removePerson(_ person: Person) {
        guard canRemovePeople else { return }
        let amount = coordinator.journey.total(for: person)
        coordinator.removePerson(id: person.id)
        removalInfo = PersonRemovalInfo(personName: person.name, amount: amount)
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
