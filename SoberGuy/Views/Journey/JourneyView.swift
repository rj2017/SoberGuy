//
//  JourneyView.swift
//  SoberGuy
//

import SwiftUI

struct JourneyView: View {
    @State private var viewModel: JourneyViewModel

    init(coordinator: JourneyCoordinator) {
        _viewModel = State(initialValue: JourneyViewModel(coordinator: coordinator))
    }

    var body: some View {
        List(viewModel.people) { person in
            HStack {
                Text(person.name)
                Spacer()
                Text(viewModel.formattedTotal(for: person))
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Jornada")
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 12) {
                Button("Adicionar Produto") {
                    viewModel.addProductTapped()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)

                Button("Adicionar Pessoa") {
                    viewModel.addPersonTapped()
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)

                Button("Finalizar Jornada") {
                    viewModel.finishTapped()
                }
                .buttonStyle(.bordered)
                .tint(.red)
                .frame(maxWidth: .infinity)
            }
            .padding()
            .background(.bar)
        }
    }
}
