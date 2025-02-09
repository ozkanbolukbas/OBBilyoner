//
//  LoadingView.swift
//  OBBilyoner
//
//  Created by Özkan Bölükbaş on 9.02.2025.
//

import UIKit
import Lottie

final class LoadingView {

	static let shared = LoadingView()

	// MARK: - UI Elements
	private var view: UIView?
	private var animationView: LottieAnimationView?
	var isLoading: Bool = false

	// MARK: - Private Init
	private init() {
	}

	/// Show the loading animation
	func show(animationName: String = "obLoading") {
		// Make sure we have a window to add on top of
		guard let windowScene = UIApplication.shared.connectedScenes
				.compactMap({ $0 as? UIWindowScene })
				.first(where: { $0.activationState == .foregroundActive }),
			  let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow })
		else {
			return
		}

		// If overlay already exists, avoid duplication
		if view != nil {
			return
		}

		// Create a full-screen overlay
		let overlay = UIView(frame: keyWindow.bounds)
		overlay.backgroundColor = UIColor.black.withAlphaComponent(0.5)

		// Create the Lottie animation view
		let animation = LottieAnimation.named(animationName)
		let lottieView = LottieAnimationView(animation: animation)

		// Configure Lottie animation view (size, contentMode, etc.)
		lottieView.contentMode = .scaleAspectFit
		lottieView.loopMode = .loop
		lottieView.translatesAutoresizingMaskIntoConstraints = false

		overlay.addSubview(lottieView)
		keyWindow.addSubview(overlay)

		// Layout constraints to center the animation in the overlay
		NSLayoutConstraint.activate([
			lottieView.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
			lottieView.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
			lottieView.widthAnchor.constraint(equalToConstant: 120),
			lottieView.heightAnchor.constraint(equalToConstant: 120)
		])

		// Store references
		view = overlay
		animationView = lottieView

		// Play animation
		lottieView.play()
		isLoading = true
	}

	/// Hide the loading animation
	func hide() {
		animationView?.stop()
		animationView?.removeFromSuperview()
		view?.removeFromSuperview()

		animationView = nil
		view = nil
		isLoading = false
	}
}
