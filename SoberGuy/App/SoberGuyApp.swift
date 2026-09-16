//
//  SoberGuyApp.swift
//  SoberGuy
//
//  Created by Raphael Bonifacio on 09/09/26.
//

import SwiftUI

@main
struct SoberGuyApp: App {
    @State private var appCoordinator = AppCoordinator()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            RootView(appCoordinator: appCoordinator)
        }
        .onChange(of: scenePhase) { _, newPhase in
            appCoordinator.handleScenePhaseChange(newPhase)
        }
    }
}
