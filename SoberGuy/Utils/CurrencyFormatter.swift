//
//  CurrencyFormatter.swift
//  SoberGuy
//

import Foundation

enum CurrencyFormatter {
    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.currencySymbol = "R$"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    static func string(from value: Decimal) -> String {
        formatter.string(from: NSDecimalNumber(decimal: value)) ?? "R$ 0,00"
    }
}
