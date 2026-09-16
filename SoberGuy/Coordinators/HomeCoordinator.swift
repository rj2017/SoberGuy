//
//  HomeCoordinator.swift
//  SoberGuy
//

import Foundation
import Observation
import SwiftUI

enum HomeRoute: Hashable {
    case setupPeople
}

@Observable
final class HomeCoordinator: Coordinator {
    var path = NavigationPath()
    private let persistenceService: PersistenceService
    private let onJourneyStarted: (Journey) -> Void

    init(persistenceService: PersistenceService, onJourneyStarted: @escaping (Journey) -> Void) {
        self.persistenceService = persistenceService
        self.onJourneyStarted = onJourneyStarted
    }

    func showSetupPeople() {
        path.append(HomeRoute.setupPeople)
    }

    func finishSetup(people: [Person]) {
        let journey = Journey(people: people, products: [], isFinished: false, startedAt: Date())
        persistenceService.save(journey)
        onJourneyStarted(journey)
    }
}
