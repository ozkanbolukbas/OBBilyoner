//
//  OddsResponse.swift
//  OBBilyoner
//
//  Created by Özkan Bölükbaş on 8.02.2025.
//

import Foundation

// MARK: - OddResponse
struct OddsResponse: Codable {
	let id, sportKey, sportTitle: String?
	let commenceTime: String?
	let homeTeam, awayTeam: String?
	let bookmakers: [Bookmaker]?

	enum CodingKeys: String, CodingKey {
		case id
		case sportKey = "sport_key"
		case sportTitle = "sport_title"
		case commenceTime = "commence_time"
		case homeTeam = "home_team"
		case awayTeam = "away_team"
		case bookmakers
	}
}

// MARK: - Bookmaker
struct Bookmaker: Codable {
	let key, title: String?
	let lastUpdate: String?
	let markets: [Market]?

	enum CodingKeys: String, CodingKey {
		case key, title
		case lastUpdate = "last_update"
		case markets
	}
}

// MARK: - Market
struct Market: Codable {
	let key: Key?
	let lastUpdate: String?
	let outcomes: [Outcome]?

	enum CodingKeys: String, CodingKey {
		case key
		case lastUpdate = "last_update"
		case outcomes
	}
}

enum Key: String, Codable {
	case h2H = "h2h"
	case h2HLay = "h2h_lay"
}

// MARK: - Outcome
struct Outcome: Codable {
	let name: String?
	let price: Double?
}
