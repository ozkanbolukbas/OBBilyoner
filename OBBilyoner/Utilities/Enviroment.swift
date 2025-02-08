//
//  Enviroment.swift
//  OBBilyoner
//
//  Created by Özkan Bölükbaş on 8.02.2025.
//

import Foundation

public enum Environment {

	enum Keys {
		enum Plist {
			static let baseURL = "BASE_URL"
			static let apiKey = "API_KEY"
		}
	}

	// MARK: - Plist
	private static let infoDictionary: [String: Any] = {
		guard let dict = Bundle.main.infoDictionary else {
			fatalError("Plist file not found")
		}
		return dict
	}()

	// MARK: - Plist values
	/// This function gets base url from CaseStudy.xcconfig file. For base url we can use simple constant but xcconfig file more secure than using hardcoded string. Api keys and for other strings it can be used like that.
	static let baseURL: String = {
		guard let baseURL = Environment.infoDictionary[Keys.Plist.baseURL] as? String else {
			fatalError("Root URL not set in plist for this environment")
		}
		return baseURL
	}()

	static let apiKey: String = {
		guard let apiKey = Environment.infoDictionary[Keys.Plist.apiKey] as? String else {
			fatalError("API Key not set in plist for this environment")
		}
		return apiKey
	}()
}

