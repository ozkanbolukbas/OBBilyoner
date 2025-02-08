//
//  APIError.swift
//  OBBilyoner
//
//  Created by Özkan Bölükbaş on 8.02.2025.
//
enum APIError: Error {
	/// Thrown when JSON decoding fails
	case decodingError(String)
	/// Thrown when Alamofire or lower-level networking fails
	case underlying(Error)
	/// Thrown for unexpected situations
	case unknown(String)

	var localizedDescription: String {
		switch self {
		case .decodingError(let message):
			return "Decoding Error: \(message)"
		case .underlying(let error):
			return "Network Error: \(error.localizedDescription)"
		case .unknown(let message):
			return "Unknown Error: \(message)"
		}
	}
}
