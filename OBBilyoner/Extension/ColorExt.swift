//
//  ColorExt.swift
//  OBBilyoner
//
//  Created by Özkan Bölükbaş on 10.02.2025.
//


import UIKit

extension UIColor {

	static let globe = UIColor(hex: "#1C1B20")
	static let island = UIColor(hex: "#24232A")
	static let onIsland = UIColor(hex: "#313038")
	static let primaryColor = UIColor(hex: "#775CDF")

	static let textWhite = UIColor(hex: "#FFFFFF")
	static let textPrimary = UIColor(hex: "#B19CFF")
	static let textSecondary = UIColor(hex: "#B5DB1C")




	convenience init(hex string: String) {
		var hexString = string.trimmingCharacters(in: .whitespacesAndNewlines)

		if hexString.hasPrefix("#") {
			hexString.removeFirst()
		}

		if !hexString.count.isMultiple(of: 2), let lastChar = hexString.last {
			hexString.append(lastChar)
		}

		if hexString.count > 8 {
			hexString = String(hexString.prefix(8))
		}

		let scanner = Scanner(string: hexString)
		var color: UInt64 = 0
		scanner.scanHexInt64(&color)

		if hexString.count == 2 {
			let mask = 0xFF
			let grayValue = CGFloat(Int(color) & mask) / 255.0
			self.init(red: grayValue, green: grayValue, blue: grayValue, alpha: 1)
		} else if hexString.count == 4 {
			let mask = 0x00FF
			let grayValue = CGFloat(Int(color >> 8) & mask) / 255.0
			let alphaValue = CGFloat(Int(color) & mask) / 255.0
			self.init(red: grayValue, green: grayValue, blue: grayValue, alpha: alphaValue)
		} else if hexString.count == 6 {
			let mask = 0x0000FF
			let red   = CGFloat(Int(color >> 16) & mask) / 255.0
			let green = CGFloat(Int(color >> 8) & mask) / 255.0
			let blue  = CGFloat(Int(color) & mask) / 255.0
			self.init(red: red, green: green, blue: blue, alpha: 1)
		} else if hexString.count == 8 {
			let mask = 0x000000FF
			let red   = CGFloat(Int(color >> 24) & mask) / 255.0
			let green = CGFloat(Int(color >> 16) & mask) / 255.0
			let blue  = CGFloat(Int(color >> 8) & mask) / 255.0
			let alpha = CGFloat(Int(color) & mask) / 255.0
			self.init(red: red, green: green, blue: blue, alpha: alpha)
		} else {
			self.init(red: 1, green: 1, blue: 1, alpha: 1)
		}
	}
}
