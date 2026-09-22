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
        @Bindable var viewModel = viewModel

        List(viewModel.people) { person in
            HStack {
                Text(person.name)
                Spacer()
                Text(viewModel.formattedTotal(for: person))
                    .foregroundStyle(.secondary)
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                if viewModel.canRemovePeople {
                    Button(role: .destructive) {
                        viewModel.removePerson(person)
                    } label: {
                        Label("Remover", systemImage: "trash")
                    }
                }
            }
        }
        .navigationTitle("Jornada")
        .alert(
            "Pessoa removida",
            isPresented: Binding(
                get: { viewModel.removalInfo != nil },
                set: { isPresented in
                    if !isPresented { viewModel.removalInfo = nil }
                }
            ),
            presenting: viewModel.removalInfo
        ) { _ in
            Button("OK", role: .cancel) {}
        } message: { info in
            Text("\(info.personName) deve pagar \(CurrencyFormatter.string(from: info.amount)).")
        }
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
