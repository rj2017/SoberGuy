//
//  SetupPeopleView.swift
//  SoberGuy
//

import SwiftUI

struct SetupPeopleView: View {
    @State private var viewModel: SetupPeopleViewModel

    init(coordinator: HomeCoordinator) {
        _viewModel = State(initialValue: SetupPeopleViewModel(coordinator: coordinator))
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        Form {
            Section {
                ForEach($viewModel.people) { $draft in
                    TextField("Nome", text: $draft.name)
                        .autocorrectionDisabled()
                        .overlay(alignment: .trailing) {
                            if viewModel.duplicateNameIDs.contains(draft.id) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(.red)
                            }
                        }
                }
                .onDelete(perform: viewModel.removePerson)

                Button("Adicionar Pessoa") {
                    viewModel.addPerson()
                }
            }

            if let errorMessage = viewModel.errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Quem está na mesa?")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Confirmar") {
                    viewModel.confirm()
                }
                .disabled(!viewModel.canConfirm)
            }
        }
    }
}
