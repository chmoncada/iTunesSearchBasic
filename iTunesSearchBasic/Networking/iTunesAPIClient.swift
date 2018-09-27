//
//  iTunesAPIClient.swift
//  iTunesSearchBasic
//
//  Created by Charles Moncada on 27/09/18.
//  Copyright © 2018 Charles Moncada. All rights reserved.
//

import Foundation

struct iTunesSearchResponse: Decodable {
	let resultCount: Int
	let results: [Song]
}

protocol iTunesAPIClientProtocol: class {
	func search(for term: String, page: Int, completion: @escaping (iTunesAPIClient.Result<iTunesSearchResponse, iTunesAPIClient.Error>) -> Void)
	func fetchSongList(for collectionId: Int, completion: @escaping (iTunesAPIClient.Result<iTunesSearchResponse, iTunesAPIClient.Error>) -> Void)
}

final class iTunesAPIClient: iTunesAPIClientProtocol {

	typealias iTunesResult = iTunesAPIClient.Result<iTunesSearchResponse, iTunesAPIClient.Error>
	typealias ResponseHandler = (iTunesResult) -> Void

	var isDebug = false
	private let base = "itunes.apple.com"
	private let session: URLSession

	init(session: URLSession = URLSession.shared, debug: Bool = false) {
		self.session = session
		self.isDebug = debug
	}

	func search(for term: String, page: Int = 1, completion: @escaping ResponseHandler) {

		let maxResultsPerPage = 20
		let query = "media=music&entity=song&term=\(term)&offset=\((page-1)*maxResultsPerPage)&limit=\(maxResultsPerPage)"

		guard let url = url(withPath: "/search", query: query) else {
			completion(.failure(.invalidURL))
			return
		}

		let task = buildSongTask(withURL: url, completion: completion)

		task.resume()
	}

	func fetchSongList(for collectionId: Int, completion: @escaping ResponseHandler) {

		let query = "id=\(collectionId)&entity=song"

		guard let url = url(withPath: "/lookup", query: query) else {
			// TODO
			return
		}

		let task = buildSongTask(withURL: url, completion: completion)

		task.resume()

	}

	// MARK: - Helper

	private func buildSongTask(withURL url: URL, completion: @escaping ResponseHandler) -> URLSessionDataTask {
		return session.dataTask(with: url) { [weak self] data, response, error in

			guard let httpResponse = response as? HTTPURLResponse else {
				self?.complete(with: .failure(.invalidServerResponse), completionHandler: completion)
				return
			}

			// check for successful status code
			guard 200...299 ~= httpResponse.statusCode else {
				self?.complete(with: .failure(.serverError(httpResponse.statusCode)), completionHandler: completion)
				return
			}

			// check for valid data
			guard let data = data else {
				self?.complete(with: .failure(.missingData), completionHandler: completion)
				return
			}

			// try to decode the response json
			do {
				let decoder = JSONDecoder()
				let responseData = try decoder.decode(iTunesSearchResponse.self, from: data)
				self?.complete(with: .success(responseData), completionHandler: completion)
			} catch {
				self?.complete(with: .failure(.invalidJSON(error)), completionHandler: completion)
			}
		}
	}

	private func complete(with result: iTunesResult, completionHandler: @escaping ResponseHandler) {
		DispatchQueue.main.async {
			completionHandler(result)
		}
	}

	private func buildAlbumTask(withURL url: URL, completion: @escaping ResponseHandler) -> URLSessionDataTask {
		return session.dataTask(with: url) { [weak self] data, response, error in

			guard let httpResponse = response as? HTTPURLResponse else {
				self?.albumComplete(with: .failure(.invalidServerResponse), completionHandler: completion)
				return
			}

			// check for successful status code
			guard 200...299 ~= httpResponse.statusCode else {
				self?.albumComplete(with: .failure(.serverError(httpResponse.statusCode)), completionHandler: completion)
				return
			}

			// check for valid data
			guard let data = data else {
				self?.albumComplete(with: .failure(.missingData), completionHandler: completion)
				return
			}

			// try to decode the response json
			do {
				let decoder = JSONDecoder()
				let responseData = try decoder.decode(iTunesSearchResponse.self, from: data)
				self?.albumComplete(with: .success(responseData), completionHandler: completion)
			} catch {
				self?.albumComplete(with: .failure(.invalidJSON(error)), completionHandler: completion)
			}
		}
	}

	private func albumComplete(with result: iTunesResult, completionHandler: @escaping ResponseHandler) {
		DispatchQueue.main.async {
			completionHandler(result)
		}
	}

	// MARK: - URL

	private func url(withPath path: String, query: String) -> URL? {
		var components = URLComponents()
		components.scheme = "https"
		components.host = base
		components.path = path
		components.query = query
		return components.url
	}
}
