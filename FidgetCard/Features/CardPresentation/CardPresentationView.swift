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
                            .frame(width: 400, height: 400)
                            .rotationEffect(.degrees(bgRotationDegrees))
                            .opacity(colorScheme == .dark ? 0.1 : 1.0)
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
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color(.systemBackground))
    }

    private var textStack: some View {
        VStack(spacing: 12) {
            Text("Application Prepared")
                .font(.title2.weight(.semibold))

            Text("Print it, sign it, and send it to your job")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var footer: some View {
        VStack(spacing: 24) {
            textStack

            Button {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    dismiss()
                }
            } label: {
                Text("Download the Application")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(Color(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0))
                    .frame(width: 300, height: 56)
                    .background(Color(red: 1.0, green: 221.0 / 255.0, blue: 45.0 / 255.0))
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(.horizontal, 24)
    }
}
