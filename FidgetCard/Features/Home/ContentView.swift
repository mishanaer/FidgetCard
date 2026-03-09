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
    @State private var buttonScale: CGFloat = 1.0

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
            .scaleEffect(buttonScale)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if buttonScale != 0.96 {
                            withAnimation(.easeOut(duration: 0.08)) {
                                buttonScale = 0.96
                            }
                        }
                    }
                    .onEnded { _ in
                        withAnimation(.easeOut(duration: 0.12)) {
                            buttonScale = 1.0
                        }
                    }
            )
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
