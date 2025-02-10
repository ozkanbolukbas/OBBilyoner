//
//  BasketEventCell.swift
//  OBBilyoner
//
//  Created by Özkan Bölükbaş on 9.02.2025.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class BasketEventCell: UITableViewCell {
	static let reuseIdentifier = "BasketEventCell"

	var disposeBag = DisposeBag()

	//  UI Elements
	private let containerView: UIView = {
		let view = UIView()
		view.backgroundColor = .systemGray6
		view.layer.cornerRadius = 12
		view.backgroundColor = .island
		return view
	}()

	private let teamsLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 16, weight: .medium)
		label.numberOfLines = 2
		label.textColor = .textWhite
		return label
	}()

	private let timeLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 14)
		label.textColor = .textTertiary
		return label
	}()

	private let oddsLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 16, weight: .bold)
		label.textColor = .primaryColor
		return label
	}()

	let removeButton: UIButton = {
		let button = UIButton(type: .system)
		button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
		button.tintColor = .systemRed
		return button
	}()

	var currentEvent: BasketModel?

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupUI()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// Prepare for Reuse
	override func prepareForReuse() {
		super.prepareForReuse()
		disposeBag = DisposeBag()
		currentEvent = nil
	}

	// Setup UI
	private func setupUI() {
		selectionStyle = .none
		backgroundColor = .clear

		contentView.addSubview(containerView)
		containerView.addSubview(teamsLabel)
		containerView.addSubview(timeLabel)
		containerView.addSubview(oddsLabel)
		containerView.addSubview(removeButton)

		containerView.snp.makeConstraints { make in
			make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
		}

		teamsLabel.snp.makeConstraints { make in
			make.top.leading.equalToSuperview().offset(16)
			make.trailing.equalTo(removeButton.snp.leading).offset(-8)
		}

		timeLabel.snp.makeConstraints { make in
			make.top.equalTo(teamsLabel.snp.bottom).offset(8)
			make.leading.equalToSuperview().offset(16)
		}

		oddsLabel.snp.makeConstraints { make in
			make.top.equalTo(timeLabel.snp.bottom).offset(8)
			make.leading.equalToSuperview().offset(16)
			make.bottom.equalToSuperview().offset(-16)
		}

		removeButton.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(16)
			make.trailing.equalToSuperview().offset(-16)
			make.width.height.equalTo(24)
		}
	}

	// Configure cell with data
	func configure(with event: BasketModel) {
		currentEvent = event
		teamsLabel.text = "\(event.odd.homeTeam ?? "") vs \(event.odd.awayTeam ?? "")"

		if let commenceTime = event.odd.commenceTime {
			timeLabel.isHidden = false
			timeLabel.text = formattedCommenceTime(from: commenceTime)
		} else {
			timeLabel.isHidden = true
		}

		var selectedOdds: Double?
		if let outcomes = event.odd.bookmakers?.first?.markets?.first?.outcomes {
			switch event.index {
			case 0:
				selectedOdds = outcomes.first(where: { $0.name == event.odd.homeTeam })?.price
			case 1:
				selectedOdds = outcomes.first(where: { $0.name == event.odd.awayTeam })?.price
			case 2:
				selectedOdds = outcomes.first(where: { $0.name == "Draw" })?.price
			default:
				selectedOdds = nil
			}
		}

		if let odds = selectedOdds {
			oddsLabel.text = String(format: "%.2f", odds)
		} else {
			oddsLabel.text = "-"
		}
	}

	// Format time to show today tomorrow style date.
	func formattedCommenceTime(from isoString: String) -> String {
		let isoFormatter = ISO8601DateFormatter()
		guard let date = isoFormatter.date(from: isoString) else {
			return "N/A"
		}

		let calendar = Calendar.current
		let timeFormatter = DateFormatter()
		timeFormatter.dateFormat = "HH:mm"
		let timeString = timeFormatter.string(from: date)

		if calendar.isDateInToday(date) {
			return "Bugün \(timeString)"
		} else if calendar.isDateInTomorrow(date) {
			return "Yarın \(timeString)"
		} else {
			let weekdayFormatter = DateFormatter()
			weekdayFormatter.dateFormat = "EEEE"
			let weekdayString = weekdayFormatter.string(from: date)
			return "\(weekdayString) \(timeString)"
		}
	}


}
