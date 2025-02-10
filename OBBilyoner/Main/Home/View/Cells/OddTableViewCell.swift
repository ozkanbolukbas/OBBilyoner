//
//  OddTableViewCell.swift
//  OBBilyoner
//
//  Created by Özkan Bölükbaş on 9.02.2025.
//

import UIKit
import RxSwift
import RxCocoa

class OddTableViewCell: UITableViewCell {
	static let reuseId = "OddTableViewCell"

	@IBOutlet weak var cellContentView: UIView!
	@IBOutlet weak var teamsLabel: UILabel!
	@IBOutlet weak var firstTeamView: UIView!
	@IBOutlet weak var firstTeamOddLabel: UILabel!
	@IBOutlet weak var firstTeamInfoLabel: UILabel!
	@IBOutlet weak var drawView: UIView!
	@IBOutlet weak var drawOddLabel: UILabel!
	@IBOutlet weak var drawInfoLabel: UILabel!
	@IBOutlet weak var secondTeamView: UIView!
	@IBOutlet weak var secondTeamOddLabel: UILabel!
	@IBOutlet weak var secondTeamInfoLabel: UILabel!

	var disposeBag = DisposeBag()
	// A separate dispose bag for gesture subscriptions that should persist for the lifetime of the cell
	private let gestureDisposeBag = DisposeBag()

	private let oddSelectedSubject = PublishSubject<Int>()
	var currentEvent: OddsResponse?

	var oddSelected: Observable<Int> {
		return oddSelectedSubject.asObservable()
	}

	override func awakeFromNib() {
		super.awakeFromNib()
		setupUI()
		setupGestures()
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		disposeBag = DisposeBag()
		resetViews()
		currentEvent = nil
	}

	// MARK: - UI Setup
	private func setupUI() {
		cellContentView.layer.cornerRadius = 10
		cellContentView.clipsToBounds = true

		let views = [firstTeamView, secondTeamView, drawView]
		views.forEach { view in
			view?.layer.borderColor = UIColor.black.cgColor
			view?.layer.borderWidth = 1.0
			view?.layer.cornerRadius = 10
			view?.clipsToBounds = true
			view?.backgroundColor = .white
		}

		resetViews()
	}

	// Setup Gesture recognizers
	private func setupGestures() {
		let views: [(UIView?, Int)] = [
			(firstTeamView, 0),
			(secondTeamView, 1),
			(drawView, 2)
		]

		views.forEach { view, index in
			guard let view = view else { return }
			view.isUserInteractionEnabled = true

			let gesture = UITapGestureRecognizer()
			view.addGestureRecognizer(gesture)

			gesture.rx.event
				.map { _ in index }
				.do(onNext: { [weak self] index in
					self?.animateViewTap(at: index)
				})
				.bind(to: oddSelectedSubject)
				.disposed(by: gestureDisposeBag)
		}
	}

	// MARK: - Configuration
	func configure(with item: OddsResponse, basketUpdates: Driver<Set<String>>) {
		currentEvent = item
		teamsLabel.text = "\(item.homeTeam ?? "") - \(item.awayTeam ?? "")"

		configureOdds(with: item)
		bindBasketUpdates(basketUpdates, eventId: item.id ?? "")
	}

	private func configureOdds(with item: OddsResponse) {
		guard let bookmaker = item.bookmakers?.first,
			  let outcomes = bookmaker.markets?.first?.outcomes else {
			return
		}

		resetViews()
		
		outcomes.forEach { outcome in
			switch outcome.name {
			case item.homeTeam:
				configureOddView(
					view: firstTeamView,
					oddLabel: firstTeamOddLabel,
					infoLabel: firstTeamInfoLabel,
					price: outcome.price,
					info: "MS 1"
				)
			case item.awayTeam:
				configureOddView(
					view: secondTeamView,
					oddLabel: secondTeamOddLabel,
					infoLabel: secondTeamInfoLabel,
					price: outcome.price,
					info: "MS 2"
				)
			case "Draw":
				configureOddView(
					view: drawView,
					oddLabel: drawOddLabel,
					infoLabel: drawInfoLabel,
					price: outcome.price,
					info: "MS X"
				)
			default:
				break
			}
		}
	}

	// Created binding for basket item update
	private func bindBasketUpdates(_ updates: Driver<Set<String>>, eventId: String) {
		let views = [
			(firstTeamView, 0),
			(secondTeamView, 1),
			(drawView, 2)
		]

		views.forEach { view, index in
			updates
				.map { $0.contains("\(eventId)-\(index)") }
				.drive(onNext: { [weak self] isSelected in
					self?.updateViewSelection(view, isSelected: isSelected)
				})
				.disposed(by: disposeBag)
		}
	}

	// Reset Views to prevent reused cell cofiguration
	private func resetViews() {
		[firstTeamView, secondTeamView, drawView].forEach { view in
			view?.isHidden = true
			view?.backgroundColor = .white
		}
	}

	private func configureOddView(
		view: UIView?,
		oddLabel: UILabel,
		infoLabel: UILabel,
		price: Double?,
		info: String
	) {
		view?.isHidden = false
		oddLabel.text = String(format: "%.2f", price ?? 0.0)
		infoLabel.text = info
	}

	// Animate odd selection
	private func updateViewSelection(_ view: UIView?, isSelected: Bool) {
		UIView.animate(withDuration: 0.2) {
			view?.backgroundColor = isSelected ? .systemBlue : .white
		}
	}

	// Animate tap
	private func animateViewTap(at index: Int) {
		let viewToAnimate: UIView? = {
			switch index {
			case 0: return firstTeamView
			case 1: return secondTeamView
			case 2: return drawView
			default: return nil
			}
		}()

		guard let view = viewToAnimate else { return }

		UIView.animate(withDuration: 0.1, animations: {
			view.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
			view.alpha = 0.8
		}) { _ in
			UIView.animate(withDuration: 0.1) {
				view.transform = .identity
				view.alpha = 1.0
			}
		}
	}
}
