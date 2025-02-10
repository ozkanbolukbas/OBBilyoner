//
//  EventTableViewCell.swift
//  OBBilyoner
//
//  Created by Özkan Bölükbaş on 10.02.2025.
//

import UIKit
import SnapKit

class EventTableViewCell: UITableViewCell {

	static let reuseIdentifier = "EventTableViewCell"

	// MARK: - UI Elements
	private let emojiLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 20)
		label.textAlignment = .center
		return label
	}()

	private let titleLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
		label.numberOfLines = 1
		return label
	}()

	private let descriptionLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
		label.textColor = .secondaryLabel
		label.numberOfLines = 0
		return label
	}()

	// MARK: - Initializers
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupUI()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - UI Setup
	private func setupUI() {
		contentView.addSubview(emojiLabel)
		contentView.addSubview(titleLabel)
		contentView.addSubview(descriptionLabel)

		emojiLabel.snp.makeConstraints { make in
			make.leading.equalToSuperview().offset(16)
			make.top.equalToSuperview().offset(8)
			make.width.height.equalTo(30)
		}

		titleLabel.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(8)
			make.leading.equalTo(emojiLabel.snp.trailing).offset(12)
			make.trailing.equalToSuperview().offset(-16)
		}

		descriptionLabel.snp.makeConstraints { make in
			make.top.equalTo(titleLabel.snp.bottom).offset(4)
			make.leading.equalTo(titleLabel)
			make.trailing.equalToSuperview().offset(-16)
			make.bottom.equalToSuperview().offset(-8)
		}
	}

	// MARK: - Configuration
	func configure(with event: EventResponse) {
		titleLabel.text = event.title
		descriptionLabel.text = event.description
		emojiLabel.text = event.group?.eventGroupEmoji
	}
}
