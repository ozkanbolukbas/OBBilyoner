//
//  OddsTableViewCell.swift
//  OBBilyoner
//
//  Created by Özkan Bölükbaş on 9.02.2025.
//

import UIKit
import RxSwift
import RxCocoa

protocol OddsTableViewCellDelegate: AnyObject {
	func didSelectOddsItem(at index: Int, for cell: OddsTableViewCell)
}

class OddsTableViewCell: UITableViewCell {

	static let reuseId = "OddsTableViewCell"

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

	private let disposeBag = DisposeBag()
	weak var delegate: OddsTableViewCellDelegate?

	override func awakeFromNib() {
		super.awakeFromNib()
		setupCell()
		addGestureRecognizer()
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		firstTeamView.isHidden = true
		secondTeamView.isHidden = true
		drawView.isHidden = true
	}

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)

		// Configure the view for the selected state
	}

	func setupCell() {
		cellContentView.layer.cornerRadius = 10
		cellContentView.clipsToBounds = true
		for item in [firstTeamView, secondTeamView, drawView] {
			item?.layer.borderColor = UIColor.black.cgColor
			item?.layer.borderWidth = 1.0
			item?.layer.cornerRadius = 10
			item?.clipsToBounds = true
		}
		firstTeamView.isHidden = true
		secondTeamView.isHidden = true
		drawView.isHidden = true
	}



	func configure(with item: OddsResponse) {
		teamsLabel.text = (item.homeTeam ?? "") + " - " + (item.awayTeam ?? "")
		if let bookmaker = item.bookmakers?.first, let outcomes = bookmaker.markets?.first?.outcomes{
			for outcome in outcomes {
				switch outcome.name {
				case item.homeTeam:
					firstTeamView.isHidden = false
					firstTeamOddLabel.text = "\(outcome.price ?? 0.0)"
					firstTeamInfoLabel.text = "MS 1"
				case item.awayTeam:
					secondTeamView.isHidden = false
					secondTeamOddLabel.text = "\(outcome.price ?? 0.0)"
					secondTeamInfoLabel.text = "MS 2"
				case "Draw":
					drawView.isHidden = false
					drawOddLabel.text = "\(outcome.price ?? 0.0)"
					drawInfoLabel.text = "MS X"
				default:
					break
				}
			}
		}
	}
	private func addGestureRecognizer() {
		firstTeamView?.isUserInteractionEnabled = true
		let firstTeamGesture = UITapGestureRecognizer()
		firstTeamView?.addGestureRecognizer(firstTeamGesture)

		secondTeamView?.isUserInteractionEnabled = true
		let secondTeamGesture = UITapGestureRecognizer()
		secondTeamView?.addGestureRecognizer(secondTeamGesture)

		drawView?.isUserInteractionEnabled = true
		let drawGesture = UITapGestureRecognizer()
		drawView?.addGestureRecognizer(drawGesture)

		firstTeamGesture.rx.event
			.map { _ in 0 }
			.bind { [weak self] index in
				guard let self = self else { return }
				self.handleTap(at: index)
			}
			.disposed(by: disposeBag)
		secondTeamGesture.rx.event
			.map { _ in 1 }
			.bind { [weak self] index in
				guard let self = self else { return }
				self.handleTap(at: index)
			}
			.disposed(by: disposeBag)
		drawGesture.rx.event
			.map { _ in 2 }
			.bind { [weak self] index in
				guard let self = self else { return }
				self.handleTap(at: index)
			}
			.disposed(by: disposeBag)
	}

	private func handleTap(at index: Int) {
		animateViewTap(index)
		delegate?.didSelectOddsItem(at: index, for: self)
	}

	private func animateViewTap(_ index: Int) {
		let viewToAnimate: UIView
		switch index {
		case 0: viewToAnimate = firstTeamView
		case 1: viewToAnimate = secondTeamView
		case 2: viewToAnimate = drawView
		default: return
		}

		UIView.animate(withDuration: 0.1, animations: {
			viewToAnimate.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
			viewToAnimate.alpha = 0.8
		}) { _ in
			UIView.animate(withDuration: 0.1) {
				viewToAnimate.transform = .identity
				viewToAnimate.alpha = 1.0
			}
		}
	}


}
