//
//  ApiRouter.swift
//  OBBilyoner
//
//  Created by Özkan Bölükbaş on 8.02.2025.
//

import Foundation
import Alamofire

enum APIRouter: URLRequestConvertible {
	case getEvents
	case getOdds(type: String, params: OddsRequest)


	// MARK: - HTTPMethod
	private var method: HTTPMethod {
		switch self {
		case .getEvents:
			return .get
		case .getOdds:
			return .get
		}
	}

	// MARK: - Path
	private var path: String {
		switch self {
		case .getEvents:
			return "sports"
		case .getOdds(let type, _):
			return "sports/\(type)/odds"
		}
	}

	func asURLRequest() throws -> URLRequest {
		let url = try Constants.Networking.baseURL.asURL()
		var urlRequest = URLRequest(url: url.appendingPathComponent(path))
		urlRequest.httpMethod = method.rawValue
		let parametersResult: Parameters = {
			switch self {
			case .getOdds(_, let params):
				return params.toDict()
			default:
				return [:]
			}
		}()

		var finalParameters = parametersResult
		finalParameters["api_key"] = Environment.apiKey

		let headers = urlRequest.allHTTPHeaderFields ?? [:]
		urlRequest.allHTTPHeaderFields = headers
		if (method == .post || method == .patch) {
			urlRequest = try JSONEncoding.default.encode(urlRequest, with: finalParameters)
		} else {
			urlRequest = try URLEncoding.default.encode(urlRequest, with: finalParameters)
		}
		debugPrint("------------ REQUEST -----------")
		debugPrint (urlRequest)
		debugPrint("headers: \(headers)")
		if let data = urlRequest.httpBody {
			debugPrint("parameters: \(String(decoding: data, as: UTF8.self))")
		}
		return urlRequest
	}
}

extension Encodable {
	func serialize() -> Data? {
		let encoder = JSONEncoder()
		return try? encoder.encode(self)
	}

	func prettyPrinted() -> String {
		let encoder = JSONEncoder()
		encoder.outputFormatting = .prettyPrinted
		let data = try! encoder.encode(self)
		return String(data: data, encoding: .utf8)!
	}

	func toDict() -> [String:Any] {
		do {
			return try JSONSerialization.jsonObject(with: self.serialize()!, options: [] ) as! [String : Any]
		} catch {
			debugPrint("Can't convert to dictionary")
			return [:]
		}
	}
}
