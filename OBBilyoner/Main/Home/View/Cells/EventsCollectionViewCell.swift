//
//  EventsCollectionViewCell.swift
//  OBBilyoner
//
//  Created by Özkan Bölükbaş on 9.02.2025.
//

import UIKit

class EventsCollectionViewCell: UICollectionViewCell {

	static let reuseId = "EventsCollectionViewCell"

	@IBOutlet weak var eventImage: UIImageView!

	@IBOutlet weak var eventTitle: UILabel!
	
	override func awakeFromNib() {
        super.awakeFromNib()
    }

	override var isSelected: Bool {
		didSet {
			if self.isSelected {
				self.backgroundColor = .systemRed
			} else {
				self.backgroundColor = .systemGreen
			}
		}
	}

	func configure(with category: EventCategory) {
		eventImage.image = UIImage(named: category.imageName)
		eventTitle.text = category.name
	}

}
