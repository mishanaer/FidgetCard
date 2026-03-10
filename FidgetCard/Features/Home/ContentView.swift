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
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(Color.brandText)
                    .frame(width: 300, height: 56)
                    .background(Color.brandYellow)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            }
            .buttonStyle(ScaleButtonStyle())
            .padding(.bottom, 24)
        }
        .onAppear {
            SceneCache.warmUp()
        }
        .sheet(isPresented: $showCard) {
            CardPresentationView()
        }
    }
}

#Preview {
    ContentView()
}
