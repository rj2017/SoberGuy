//
//  AppCoordinator.swift
//  SoberGuy
//

import Foundation
import Observation
import SwiftUI

enum AppRoute: Equatable {
    case home
    case journey
}

@Observable
final class AppCoordinator: Coordinator {
    private(set) var root: AppRoute
    private(set) var activeJourney: Journey?
    let persistenceService: PersistenceService

    init(persistenceService: PersistenceService = UserDefaultsPersistenceService()) {
        self.persistenceService = persistenceService

        if let journey = persistenceService.loadJourney() {
            if journey.isFinished {
                // Caso defensivo: não deveria acontecer na prática, pois o
                // cache é limpo ao encerrar o app com isFinished == true.
                persistenceService.clearJourney()
                root = .home
                activeJourney = nil
            } else {
                root = .journey
                activeJourney = journey
            }
        } else {
            root = .home
            activeJourney = nil
        }
    }

    func startJourney(with journey: Journey) {
        activeJourney = journey
        root = .journey
    }

    func returnToHome() {
        activeJourney = nil
        root = .home
    }

    func handleScenePhaseChange(_ phase: ScenePhase) {
        guard phase == .background else { return }
        // Relê do disco (não do estado em memória) para permanecer correto
        // mesmo após uma etapa futura mutar isFinished diretamente via
        // persistenceService a partir de uma JourneyViewModel.
        if let journey = persistenceService.loadJourney(), journey.isFinished {
            persistenceService.clearJourney()
        }
    }
}
