//
//  RootView.swift
//  SoberGuy
//

import SwiftUI

struct RootView: View {
    let appCoordinator: AppCoordinator

    var body: some View {
        switch appCoordinator.root {
        case .home:
            HomeCoordinatorView(
                persistenceService: appCoordinator.persistenceService,
                onJourneyStarted: appCoordinator.startJourney
            )
        case .journey:
            if let journey = appCoordinator.activeJourney {
                JourneyCoordinatorView(
                    journey: journey,
                    persistenceService: appCoordinator.persistenceService,
                    onClosed: appCoordinator.returnToHome
                )
            }
        }
    }
}
