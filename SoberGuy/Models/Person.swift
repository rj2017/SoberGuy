//
//  Person.swift
//  SoberGuy
//

import Foundation

struct Person: Identifiable, Codable {
    let id: UUID
    var name: String
    let joinedAt: Date
}
