//
//  AnalyticsManager.swift
//  OBBilyoner
//
//  Created by Özkan Bölükbaş on 10.02.2025.
//

import FirebaseAnalytics

protocol AnalyticsService {
	func logEvent(_ name: AnalyticsEventType)
}

class AnalyticsManager {
	static let shared = AnalyticsManager()

	func log(_ event: AnalyticsEventType) {
		let name = event.name()
		let parameters = event.parameters()
		Analytics.logEvent(name, parameters: parameters)
	}
}


enum AnalyticsEventType {
	case addBetToCart(id: String, homeTeam: String, awayTeam: String, bet: String)
	case removeBetFromCart(id: String, homeTeam: String, awayTeam: String, bet: String)
	case updateBetFromCart(id: String, homeTeam: String, awayTeam: String, bet: String)
	case eventDetail(title: String, description: String, key: String)

}

extension AnalyticsEventType {

	func name() -> String {
		switch self {
		case .addBetToCart: return "add_bet_to_cart"
		case .removeBetFromCart: return "remove_bet_from_cart"
		case .updateBetFromCart: return "update_bet_from_cart"
		case .eventDetail: return "event_detail"
		}
	}

	func parameters() -> [String: Any]? {
		switch self {
		case .addBetToCart(let id, let homeTeam, let awayTeam, let bet),
			 .removeBetFromCart(let id, let homeTeam, let awayTeam, let bet),
			 .updateBetFromCart(let id, let homeTeam, let awayTeam, let bet):
			return [
				"id": id,
				"home_team": homeTeam,
				"away_team": awayTeam,
				"bet": bet
			]
		case .eventDetail(let title, let description, let key):
			return [
				"title": title,
				"description": description,
				"key": key
			]
		}
	}
}
