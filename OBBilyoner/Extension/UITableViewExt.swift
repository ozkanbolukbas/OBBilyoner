//
//  UITableViewExt.swift
//  OBBilyoner
//
//  Created by Özkan Bölükbaş on 9.02.2025.
//

import UIKit

public extension UITableView {
	func register<T: UITableViewCell>(cellType: T.Type) {
			let className = String(describing: cellType)
			if Bundle.main.path(forResource: className, ofType: "nib") != nil {
				let nib = UINib(nibName: className, bundle: nil)
				self.register(nib, forCellReuseIdentifier: className)
			} else {
				self.register(cellType, forCellReuseIdentifier: className)
			}
		}

	func dequeueReusableCell<T: UITableViewCell>(with type: T.Type, for indexPath: IndexPath) -> T {
		return self.dequeueReusableCell(withIdentifier: type.className, for: indexPath) as! T
	}

}
