//
//  Product.swift
//  SoberGuy
//

import Foundation

struct Product: Identifiable, Codable {
    let id: UUID
    var name: String
    var value: Decimal
    let addedAt: Date
    let participantIds: [UUID] // snapshot das pessoas presentes no momento
}
