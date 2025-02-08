//
//  OddsRequest.swift
//  OBBilyoner
//
//  Created by Özkan Bölükbaş on 8.02.2025.
//

struct OddsRequest: Codable {
	let markets: String
	let regions: String

	func getEuRegionWithH2H() -> OddsRequest {
		return OddsRequest(markets: "h2h", regions: "eu")
	}
}
