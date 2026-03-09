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
                    .foregroundStyle(Color(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0))
                    .frame(width: 300, height: 56)
                    .background(Color(red: 1.0, green: 221.0 / 255.0, blue: 45.0 / 255.0))
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
