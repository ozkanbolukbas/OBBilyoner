//
//  ArrayExt.swift
//  OBBilyoner
//
//  Created by Özkan Bölükbaş on 9.02.2025.
//

extension Array {
	subscript(safe index: Int) -> Element? {
		return indices.contains(index) ? self[index] : nil
	}
}
