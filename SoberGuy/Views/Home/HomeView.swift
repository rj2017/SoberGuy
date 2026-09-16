//
//  HomeView.swift
//  SoberGuy
//

import SwiftUI

struct HomeView: View {
    @State private var viewModel: HomeViewModel

    init(coordinator: HomeCoordinator) {
        _viewModel = State(initialValue: HomeViewModel(coordinator: coordinator))
    }

    var body: some View {
        VStack {
            Button("Iniciar Jornada") {
                viewModel.startJourneyTapped()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("soberGuy")
    }
}
