//
//  CardPresentationView.swift
//  FidgetCard
//
//  Created by Misha Naer on 07.03.2026.
//

import SwiftUI

struct CardPresentationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var bgRotationDegrees: Double = 0

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Rotating3DView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background {
                        Image("BG")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 520, height: 520)
                            .rotationEffect(.degrees(bgRotationDegrees))
                            .opacity(colorScheme == .dark ? 0.07 : 0.8)
                            .allowsHitTesting(false)
                            .onAppear {
                                bgRotationDegrees = 0
                                withAnimation(.linear(duration: 12).repeatForever(autoreverses: false)) {
                                    bgRotationDegrees = 360
                                }
                            }
                    }
                    .offset(y: -120)

                footer
                    .padding(.bottom, 24)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .accessibilityLabel("Close")
                }
            }
        }
        .onAppear {
            SceneCache.restartAnimation()
        }
        .presentationDetents([.fraction(0.7)])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color(.systemBackground))
    }

    private var textStack: some View {
        VStack(spacing: 12) {
            Text("Application is ready")
                .font(.title2.weight(.semibold))

            Text("Print it and have your employer\nsign it at work")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var footer: some View {
        VStack(spacing: 32) {
            textStack

            Button {
                dismiss()
            } label: {
                Text("Download the Application")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(Color.brandText)
                    .frame(width: 300, height: 56)
                    .background(Color.brandYellow)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(.horizontal, 24)
    }
}
