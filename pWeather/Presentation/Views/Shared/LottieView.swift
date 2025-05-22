/*
*  File: LottieView.swift
*  Project: pWeather
*  Author: macitch.(@https://www.github.com/macitch)
*  Created: on 06.02.2025.
*  License: MIT - Copyright (C) 2025. macitch.
*/

import SwiftUI
import Lottie

/// A SwiftUI-compatible wrapper for displaying Lottie animations using `UIViewRepresentable`.
/// Allows specifying animation name, loop mode, and playback speed.
struct LottieView: UIViewRepresentable {

    // MARK: - Configuration Properties

    /// The name of the Lottie animation file (without extension).
    let name: String

    /// The looping behavior of the animation. Defaults to `.loop`.
    var loopMode: LottieLoopMode = .loop

    /// Playback speed of the animation. Defaults to `1.0`.
    var speed: CGFloat = 1.0

    // MARK: - UIViewRepresentable Lifecycle

    /// Creates and configures the `LottieAnimationView` instance.
    func makeUIView(context: Context) -> some UIView {
        let animationView = LottieAnimationView(name: name)
        animationView.loopMode = loopMode
        animationView.animationSpeed = speed
        animationView.contentMode = .scaleAspectFit
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.play() // Starts the animation immediately
        return animationView
    }

    /// Updates the view when SwiftUI state changes.
    /// Not used here as animation properties are static after creation.
    func updateUIView(_ uiView: UIViewType, context: Context) {
        // No dynamic updates required for this implementation.
    }
}
