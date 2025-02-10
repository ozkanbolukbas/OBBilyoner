//
//  StringExt.swift
//  OBBilyoner
//
//  Created by Özkan Bölükbaş on 10.02.2025.
//

extension String {
	var eventGroupEmoji: String {
		switch self {
		case "American Football":
			return "🏈"
		case "Aussie Rules":
			return "🏉"
		case "Baseball":
			return "⚾"
		case "Basketball":
			return "🏀"
		case "Boxing":
			return "🥊"
		case "Cricket":
			return "🏏"
		case "Golf":
			return "⛳"
		case "Ice Hockey":
			return "🏒"
		case "Lacrosse":
			return "🥍"
		case "Mixed Martial Arts":
			return "🥋"
		case "Rugby League", "Rugby Union":
			return "🏉"
		case "Soccer":
			return "⚽"
		case "Tennis":
			return "🎾"
		default:
			return "❓"
		}
	}
}
