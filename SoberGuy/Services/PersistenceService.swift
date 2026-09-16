//
//  PersistenceService.swift
//  SoberGuy
//

import Foundation

protocol PersistenceService {
    func loadJourney() -> Journey?
    func save(_ journey: Journey)
    func clearJourney()
}
