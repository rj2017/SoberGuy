//
//  SetupPeopleViewModel.swift
//  SoberGuy
//

import Foundation
import Observation
import SwiftUI

@Observable
final class SetupPeopleViewModel {
    struct PersonDraft: Identifiable {
        let id = UUID()
        var name: String = ""
    }

    var people: [PersonDraft] = []
    private let coordinator: HomeCoordinator

    init(coordinator: HomeCoordinator) {
        self.coordinator = coordinator
    }

    /// IDs dos rascunhos cujo nome (trimado, case-insensitive) colide com outro rascunho.
    var duplicateNameIDs: Set<UUID> {
        var seen: [String: UUID] = [:]
        var duplicates: Set<UUID> = []
        for person in people {
            let key = PersonNameValidator.normalize(person.name)
            guard !key.isEmpty else { continue }
            if let firstID = seen[key] {
                duplicates.insert(firstID)
                duplicates.insert(person.id)
            } else {
                seen[key] = person.id
            }
        }
        return duplicates
    }

    var errorMessage: String? {
        duplicateNameIDs.isEmpty ? nil : "Já existe uma pessoa com esse nome. Use nomes diferentes."
    }

    var canConfirm: Bool {
        !people.isEmpty
            && duplicateNameIDs.isEmpty
            && people.allSatisfy { !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    func addPerson() {
        people.append(PersonDraft())
    }

    func removePerson(at offsets: IndexSet) {
        people.remove(atOffsets: offsets)
    }

    func confirm() {
        guard canConfirm else { return }
        let finalPeople = people.map {
            Person(
                id: UUID(),
                name: $0.name.trimmingCharacters(in: .whitespacesAndNewlines),
                joinedAt: Date()
            )
        }
        coordinator.finishSetup(people: finalPeople)
    }
}
