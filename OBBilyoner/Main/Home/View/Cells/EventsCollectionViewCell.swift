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

	func configure(with category: EventCategory) {
		eventImage.image = UIImage(named: category.imageName)
		eventTitle.text = category.name
	}

	func updateSelection(isSelected: Bool) {
			UIView.animate(withDuration: 0.2) {
				self.backgroundColor = isSelected ? .systemBlue : .systemRed
				self.layer.borderColor = isSelected ? UIColor.systemBlue.cgColor : UIColor.systemGray5.cgColor
			}
		}

}
