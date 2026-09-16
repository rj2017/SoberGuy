//
//  AddPersonViewModel.swift
//  SoberGuy
//

import Foundation
import Observation

@Observable
final class AddPersonViewModel {
    var name: String = ""

    private let coordinator: JourneyCoordinator

    init(coordinator: JourneyCoordinator) {
        self.coordinator = coordinator
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isDuplicate: Bool {
        PersonNameValidator.isDuplicate(name, among: coordinator.journey.people.map(\.name))
    }

    var errorMessage: String? {
        isDuplicate ? "Já existe uma pessoa com esse nome. Use nomes diferentes." : nil
    }

    var canConfirm: Bool {
        !trimmedName.isEmpty && !isDuplicate
    }

    func confirm() {
        guard canConfirm else { return }
        coordinator.addPerson(name: trimmedName)
    }

    func cancel() {
        coordinator.dismissSheet()
    }
}
