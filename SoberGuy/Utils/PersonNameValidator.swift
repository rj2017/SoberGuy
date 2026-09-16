//
//  PersonNameValidator.swift
//  SoberGuy
//

import Foundation

enum PersonNameValidator {
    static func normalize(_ name: String) -> String {
        name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    static func isDuplicate(_ name: String, among existingNames: [String]) -> Bool {
        let key = normalize(name)
        guard !key.isEmpty else { return false }
        return existingNames.contains { normalize($0) == key }
    }
}
