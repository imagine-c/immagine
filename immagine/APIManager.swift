//
//  ServiceCallManager.swift
//  immagine
//
//  Created by Sanjeev Chavan on 27/12/20.
//

import Foundation

typealias ServiceResults = (Data?, Error?)

enum APIEndpoint {
	case popular(Int)
	case movieId(Int)
	
	var url: URL? {
		guard var validUrl = URL(string: baseUrl) else { return nil }
		switch self {
		case .popular(let pageNo):
			validUrl = validUrl.appendingPathComponent("/popular")
				.appending("page", value: String(pageNo))
		case .movieId(let movieId):
			validUrl = validUrl.appendingPathComponent("/\(movieId)")
				.appending("append_to_response", value: "videos")
		}
		
		return validUrl.appending("api_key", value: apiKey)
	}
}

class APIManager {
	static let shared = APIManager()
	private init() {}

	func performRequest(for endpoint: APIEndpoint,
						completion: @escaping((ServiceResults)->())) {
		guard let url = endpoint.url else { return }
		
		URLSession.shared.dataTask(with: url,
			completionHandler: { (data, response, error) in
			completion((data, error))
		}).resume()
	}
}

extension Data {
	func decode<T>() -> T? where T:Decodable {
		do {
			return try JSONDecoder().decode(T.self, from: self)
		} catch {
			return nil
		}
	}
}

extension URL {
	public func appending(_ queryItem: String, value: String?) -> URL {
		guard var urlComponents = URLComponents(string: absoluteString) else {
			return absoluteURL }
		var queryItems: [URLQueryItem] = urlComponents.queryItems ??  []
		let queryItem = URLQueryItem(name: queryItem, value: value)
		queryItems.append(queryItem)
		urlComponents.queryItems = queryItems
		return urlComponents.url!
	}
}
