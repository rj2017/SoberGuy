//
//  CurrencyTextField.swift
//  SoberGuy
//

import SwiftUI

/// Campo com máscara "R$ 00,00" onde dígitos entram pela direita. Implementado
/// como `UIViewRepresentable` + `UITextFieldDelegate` (em vez de um
/// `TextField` com `Binding(get:set:)`) porque SwiftUI não repuxa de forma
/// confiável o texto reformatado para dentro do buffer do `UITextField`
/// enquanto o campo está focado e recebendo digitação ao vivo — o delegate dá
/// controle direto e síncrono sobre o texto exibido a cada tecla.
struct CurrencyTextField: UIViewRepresentable {
    @Binding var cents: Int

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.keyboardType = .numberPad
        textField.delegate = context.coordinator
        textField.text = CurrencyFormatter.string(from: Decimal(cents) / 100)
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        context.coordinator.cents = cents
        let formatted = CurrencyFormatter.string(from: Decimal(cents) / 100)
        if uiView.text != formatted {
            uiView.text = formatted
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(cents: $cents)
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var cents: Int

        init(cents: Binding<Int>) {
            _cents = cents
        }

        func textField(
            _ textField: UITextField,
            shouldChangeCharactersIn range: NSRange,
            replacementString string: String
        ) -> Bool {
            let currentDigits = (textField.text ?? "").filter(\.isNumber)
            let newDigits: String
            if string.isEmpty {
                newDigits = String(currentDigits.dropLast())
            } else {
                newDigits = currentDigits + string.filter(\.isNumber)
            }
            let newCents = min(Int(newDigits) ?? 0, 999_999_999)
            cents = newCents
            textField.text = CurrencyFormatter.string(from: Decimal(newCents) / 100)
            return false
        }
    }
}
