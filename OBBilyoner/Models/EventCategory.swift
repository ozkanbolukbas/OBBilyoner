//
//  EventCategory.swift
//  OBBilyoner
//
//  Created by Özkan Bölükbaş on 9.02.2025.
//

struct EventCategory {
	let key: String
	let name: String
	let imageName: String

	static let categories: [EventCategory] = [
		EventCategory(key: "soccer", name: "Futbol", imageName: "icFootball"),
		EventCategory(key: "basketball", name: "Basketbol", imageName: "icBasketball"),
		EventCategory(key: "americanfootball_nfl", name: "Amerikan Futbolu", imageName: "icAmericanFootball"),
		EventCategory(key: "boxing_boxing", name: "Box", imageName: "icBoxing"),
		EventCategory(key: "mma_mixed_martial_arts", name: "MMA", imageName: "icMMA"),
		EventCategory(key: "icehockey_nhl", name: "Buz Hokeyi", imageName: "icIceHokey"),
		EventCategory(key: "cricket_odi", name: "Kriket", imageName: "icCricket")
	]
}
