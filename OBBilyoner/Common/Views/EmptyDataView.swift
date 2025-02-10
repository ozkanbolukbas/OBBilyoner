//
//  EmptyDataView.swift
//  OBBilyoner
//
//  Created by Özkan Bölükbaş on 10.02.2025.
//

import UIKit
import SnapKit

class EmptyDataView: UIView {

	// MARK: UI Elements
	private let messageLabel: UILabel = {
		let label = UILabel()
		label.textAlignment = .center
		label.textColor = .textTertiary
		label.numberOfLines = 0
		return label
	}()

	let actionButton: UIButton = {
		let button = UIButton(type: .system)
		button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
		button.backgroundColor = .primaryColor
		button.setTitleColor(.white, for: .normal)
		button.layer.cornerRadius = 8
		button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
		return button
	}()

	// MARK: Initialization
	init(message: String, buttonTitle: String?) {
		super.init(frame: .zero)
		setupUI()
		messageLabel.text = message

		if let title = buttonTitle, !title.isEmpty {
			actionButton.setTitle(title, for: .normal)
			actionButton.isHidden = false
		} else {
			actionButton.isHidden = true
		}
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupUI()
	}

	// MARK: Setup UI
	private func setupUI() {
		backgroundColor = .clear

		addSubview(messageLabel)
		addSubview(actionButton)

		messageLabel.snp.makeConstraints { make in
			make.centerX.equalToSuperview()
			make.centerY.equalToSuperview().offset(actionButton.isHidden ? 0 : -20)
			make.leading.greaterThanOrEqualToSuperview().offset(16)
			make.trailing.lessThanOrEqualToSuperview().offset(-16)
		}

		actionButton.snp.makeConstraints { make in
			make.centerX.equalToSuperview()
			make.top.equalTo(messageLabel.snp.bottom).offset(16)
		}
	}
}
