//
//  Coordinator.swift
//  SoberGuy
//

import Foundation

/// Marker protocol shared by navigation-owning types (AppCoordinator,
/// HomeCoordinator, future JourneyCoordinator). Intentionally has no
/// requirements: AppCoordinator's navigation state is a root-level route
/// switch while HomeCoordinator owns a NavigationPath, so a unified
/// path/Route API would force an unnatural shape onto AppCoordinator.
protocol Coordinator: AnyObject {}
