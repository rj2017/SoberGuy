//
//  SummaryView.swift
//  SoberGuy
//

import SwiftUI

struct SummaryView: View {
    @State private var viewModel: SummaryViewModel

    init(coordinator: JourneyCoordinator) {
        _viewModel = State(initialValue: SummaryViewModel(coordinator: coordinator))
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
        .navigationTitle("Resumo")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.closeTapped()
                } label: {
                    Image(systemName: "xmark")
                }
            }
        }
    }
}
