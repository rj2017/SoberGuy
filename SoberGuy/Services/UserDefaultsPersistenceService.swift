//
//  UserDefaultsPersistenceService.swift
//  SoberGuy
//

import Foundation

final class UserDefaultsPersistenceService: PersistenceService {
    private let defaults: UserDefaults
    private let storageKey = "com.rjb.SoberGuy.activeJourney"
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    func loadJourney() -> Journey? {
        guard let data = defaults.data(forKey: storageKey) else { return nil }
        return try? decoder.decode(Journey.self, from: data)
    }

    func save(_ journey: Journey) {
        guard let data = try? encoder.encode(journey) else { return }
        defaults.set(data, forKey: storageKey)
    }

    func clearJourney() {
        defaults.removeObject(forKey: storageKey)
    }
}
