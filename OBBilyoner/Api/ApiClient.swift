//
//  ApiClient.swift
//  OBBilyoner
//
//  Created by Özkan Bölükbaş on 8.02.2025.
//

import Foundation
import Alamofire
import RxSwift


//MARK: ApiClient
///Generic api client for centralized request system and reduce repeated code blocks.
class APIClient {
	private static func handle<T: Decodable>(response: AFDataResponse<Data>, single: @escaping (SingleEvent<T>) -> Void) {
		if let data = response.data {
			debugPrint("➡️➡️➡️➡️------------ RESPONSE -----------")
			data.printAsJSON()
		}
		switch response.result {
		case .success(let data):
			do {
				let model = try JSONDecoder().decode(T.self, from: data)
				single(.success(model))
			} catch {
				debugPrint("🤦‍♂️🤦‍♂️🤦‍♂️🤦‍♂️------------ ERROR -----------")
				debugPrint("\(error)")
				let error = APIError.decodingError(error.localizedDescription)
				single(.failure(error))
			}

		case .failure(let error):
			if let data = response.data {
				single(.failure(APIError.unknown(error.localizedDescription)))
			} else {
				single(.failure(APIError.unknown("No response data.")))
			}
		}

	}

	static func request<T: Decodable>(route: APIRouter) -> Single<T> {
		return Single<T>.create { single in

			let request = AF.request(route)
				.validate()
				.responseData { response in
					handle(response: response, single: single)
				}
			return Disposables.create {
				request.cancel()
			}
		}
	}
}

extension Data {
	func printAsJSON() {
			if let theJSONData = try? JSONSerialization.jsonObject(with: self, options: []) as? NSDictionary {
				var swiftDict: [String: Any] = [:]
				for key in theJSONData.allKeys {
					let stringKey = key as? String
					if let key = stringKey, let keyValue = theJSONData.value(forKey: key) {
						swiftDict[key] = keyValue
					}
				}
				swiftDict.printAsJSON()
			}
		}
}

private extension Dictionary {
	func printAsJSON() {
		if let theJSONData = try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted),
			let theJSONText = String(data: theJSONData, encoding: String.Encoding.ascii) {
			debugPrint("\(theJSONText)")
		}
	}
}
