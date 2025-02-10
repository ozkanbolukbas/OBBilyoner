//
//  CollectionExt.swift
//  OBBilyoner
//
//  Created by Özkan Bölükbaş on 10.02.2025.
//

extension Collection {
	subscript(safe index: Index) -> Element? {
		return indices.contains(index) ? self[index] : nil
	}
}
