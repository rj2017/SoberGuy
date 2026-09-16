//
//  AddProductViewModel.swift
//  SoberGuy
//

import Foundation
import Observation

@Observable
final class AddProductViewModel {
    var name: String
    var valueCents: Int

    private let coordinator: JourneyCoordinator

    init(coordinator: JourneyCoordinator) {
        self.coordinator = coordinator
        if let last = coordinator.journey.products.last {
            name = last.name
            valueCents = NSDecimalNumber(decimal: last.value * 100).intValue
        } else {
            name = ""
            valueCents = 0
        }
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var decimalValue: Decimal {
        Decimal(valueCents) / 100
    }

    var canConfirm: Bool {
        !trimmedName.isEmpty && decimalValue > 0
    }

    func confirm() {
        guard canConfirm else { return }
        coordinator.addProduct(name: trimmedName, value: decimalValue)
    }

    func cancel() {
        coordinator.dismissSheet()
    }
}
