//
//  EventsCollectionViewCell.swift
//  OBBilyoner
//
//  Created by Özkan Bölükbaş on 9.02.2025.
//

import UIKit

class EventsCollectionViewCell: UICollectionViewCell {

	static let reuseId = "EventsCollectionViewCell"

	@IBOutlet weak var cellContentView: UIView!
	@IBOutlet weak var eventImage: UIImageView!

	@IBOutlet weak var eventTitle: UILabel!

	override func awakeFromNib() {
		super.awakeFromNib()
		setupUI()
	}

	// MARK: - UI Setup
	func setupUI() {
		cellContentView.backgroundColor = .systemRed
		eventTitle.textColor = .black
		cellContentView.layer.cornerRadius = 20
		cellContentView.layer.masksToBounds = true
		cellContentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
	}

	// MARK: - Configuration
	func configure(with category: EventCategory) {
		eventImage.image = UIImage(named: category.imageName)
		eventTitle.text = category.name

	}

	func updateSelection(isSelected: Bool) {
		UIView.animate(withDuration: 0.2) {
			self.cellContentView.backgroundColor = isSelected ? .systemBlue : .systemRed
			self.eventTitle.textColor = isSelected ? .white: .black

		}
	}

}
