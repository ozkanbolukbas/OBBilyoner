//
//  BaseViewController.swift
//  OBBilyoner
//
//  Created by Özkan Bölükbaş on 9.02.2025.
//

import Foundation
import UIKit
import RxSwift

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

	func showErrorAlert(message: String) -> Observable<Void> {
		return Observable.create { [weak self] observer in
			let alertController = UIAlertController(
				title: "Error",
				message: message,
				preferredStyle: .alert
			)
			let okAction = UIAlertAction(title: "OK", style: .default) { _ in
				observer.onNext(())
				observer.onCompleted()
			}
			alertController.addAction(okAction)
			self?.present(alertController, animated: true, completion: nil)
			return Disposables.create {
				alertController.dismiss(animated: true, completion: nil)
			}
		}
	}
}
