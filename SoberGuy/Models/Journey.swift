//
//  Journey.swift
//  SoberGuy
//

import Foundation

struct Journey: Codable {
    var people: [Person]
    var products: [Product]
    var isFinished: Bool
    var startedAt: Date
}

extension Journey {
    /// §4.4: soma, para cada produto em que a pessoa estava presente no
    /// momento do lançamento (snapshot em `participantIds`, §4.2), o valor
    /// dividido pelo número de participantes daquele produto.
    func total(for person: Person) -> Decimal {
        products
            .filter { $0.participantIds.contains(person.id) }
            .reduce(Decimal(0)) { $0 + $1.value / Decimal($1.participantIds.count) }
    }
}
