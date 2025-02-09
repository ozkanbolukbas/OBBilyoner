//
//  UICollectionViewExt.swift
//  OBBilyoner
//
//  Created by Özkan Bölükbaş on 9.02.2025.
//
import UIKit

extension UICollectionView {
	func register<T: UICollectionViewCell>(cellType: T.Type, bundle: Bundle? = nil) {
		let className = cellType.className
		let nib = UINib(nibName: className, bundle: bundle)
		register(nib, forCellWithReuseIdentifier: className)
	}

	func register<T: UICollectionViewCell>(cellTypes: [T.Type], bundle: Bundle? = nil) {
		cellTypes.forEach { register(cellType: $0, bundle: bundle) }
	}
}
