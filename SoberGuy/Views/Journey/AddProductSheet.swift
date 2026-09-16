//
//  AddProductSheet.swift
//  SoberGuy
//

import SwiftUI

struct AddProductSheet: View {
    @State private var viewModel: AddProductViewModel

    init(coordinator: JourneyCoordinator) {
        _viewModel = State(initialValue: AddProductViewModel(coordinator: coordinator))
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        Form {
            TextField("Nome do produto", text: $viewModel.name)
                .autocorrectionDisabled()
            CurrencyTextField(cents: $viewModel.valueCents)
        }
        .navigationTitle("Adicionar Produto")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancelar") {
                    viewModel.cancel()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Adicionar") {
                    viewModel.confirm()
                }
                .disabled(!viewModel.canConfirm)
            }
        }
    }
}
