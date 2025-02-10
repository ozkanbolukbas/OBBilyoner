//
//  EventResponse.swift
//  OBBilyoner
//
//  Created by Özkan Bölükbaş on 10.02.2025.
//

// MARK: - EventResponse
struct EventResponse: Codable {
	let key, group, title, description: String?
	let active: Bool?

	enum CodingKeys: String, CodingKey {
		case key
		case group
		case title
		case description
		case active
	}
}
