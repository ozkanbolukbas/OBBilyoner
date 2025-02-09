//
//  BaseViewController.swift
//  OBBilyoner
//
//  Created by Özkan Bölükbaş on 9.02.2025.
//

import Foundation
import UIKit

class BaseViewController: UIViewController, UIGestureRecognizerDelegate {
	var isLoading: Bool {
		get {
			return LoadingView.shared.isLoading
		}
		set {
			newValue ? LoadingView.shared.show() : LoadingView.shared.hide()
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.interactivePopGestureRecognizer?.delegate = self
	}

	func showErrorAlert(message: String) {
		let alertController = UIAlertController(
			title: "Error",
			message: message,
			preferredStyle: .alert
		)
		alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		self.present(alertController, animated: true, completion: nil)
	}
}
