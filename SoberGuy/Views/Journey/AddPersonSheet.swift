//
//  AddPersonSheet.swift
//  SoberGuy
//

import SwiftUI

struct AddPersonSheet: View {
    @State private var viewModel: AddPersonViewModel

    init(coordinator: JourneyCoordinator) {
        _viewModel = State(initialValue: AddPersonViewModel(coordinator: coordinator))
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        Form {
            Section {
                TextField("Nome", text: $viewModel.name)
                    .autocorrectionDisabled()
            }

            if let errorMessage = viewModel.errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Adicionar Pessoa")
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
