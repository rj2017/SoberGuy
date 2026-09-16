//
//  JourneyCoordinator.swift
//  SoberGuy
//

import Foundation
import Observation
import SwiftUI

enum JourneySheetRoute: Identifiable {
    case addProduct
    case addPerson

    var id: Self { self }
}

enum JourneyRoute: Hashable {
    case summary
}

@Observable
final class JourneyCoordinator: Coordinator {
    private(set) var journey: Journey
    var sheetRoute: JourneySheetRoute?
    var path = NavigationPath()

    private let persistenceService: PersistenceService
    private let onClosed: () -> Void

    init(journey: Journey, persistenceService: PersistenceService, onClosed: @escaping () -> Void) {
        self.journey = journey
        self.persistenceService = persistenceService
        self.onClosed = onClosed
    }

    func showAddProduct() {
        sheetRoute = .addProduct
    }

    func showAddPerson() {
        sheetRoute = .addPerson
    }

    func dismissSheet() {
        sheetRoute = nil
    }

    func addProduct(name: String, value: Decimal) {
        let product = Product(
            id: UUID(),
            name: name,
            value: value,
            addedAt: Date(),
            participantIds: journey.people.map(\.id)
        )
        journey.products.append(product)
        persistenceService.save(journey)
        sheetRoute = nil
    }

    func addPerson(name: String) {
        let person = Person(id: UUID(), name: name, joinedAt: Date())
        journey.people.append(person)
        persistenceService.save(journey)
        sheetRoute = nil
    }

    func finish() {
        journey.isFinished = true
        persistenceService.save(journey)
        path.append(JourneyRoute.summary)
    }

    func closeSummary() {
        persistenceService.clearJourney()
        onClosed()
    }
}
