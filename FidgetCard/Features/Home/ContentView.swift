//
//
//  ContentView.swift
//  FidgetCard
//
//  Created by Misha Naer on 07.03.2026.
//

import SwiftUI

struct ContentView: View {
    @State private var showCard = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.systemBackground).ignoresSafeArea()

            Button {
                showCard = true
            } label: {
                Text("Open Sheet")
            }
            .controlSize(.extraLarge)
            .buttonStyle(.borderedProminent)
            .padding(.bottom, 24)
        }
        .sheet(isPresented: $showCard) {
            CardPresentationView()
        }
    }
}

#Preview {
    ContentView()
}
