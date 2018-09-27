//
//  MockURLSession.swift
//  iTunesSearchBasicTests
//
//  Created by Charles Moncada on 27/09/18.
//  Copyright © 2018 Charles Moncada. All rights reserved.
//

import Foundation
@testable import iTunesSearchBasic

final class MockURLSession: URLSession {

	// MARK: - Types

	private final class Task: URLSessionDataTask {

		private let completion: () -> Void

		init(completion: @escaping () -> Void) {
			self.completion = completion
			super.init()
		}

		override func resume() {
			completion()
		}
	}

	// MARK: - Properties

	private let handler: (URL) -> (iTunesAPIClient.Result<(Data?, URLResponse?), iTunesAPIClient.Error>)

	var completedURLs = [URL]()

	// MARK: - Init

	init(handler: @escaping (URL) -> (iTunesAPIClient.Result<(Data?, URLResponse?), iTunesAPIClient.Error>)) {
		self.handler = handler
	}

	// MARK: - Task

	override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
		return Task {
			self.completedURLs.append(url)
			switch self.handler(url) {
			case .success(let data, let response):
				completionHandler(data, response, nil)
			case .failure(let error):
				completionHandler(nil, nil, error)
			}
		}
	}
}

extension MockURLSession {

	static var empty: MockURLSession {
		return MockURLSession { url in
			let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
			let data = try? JSONSerialization.data(withJSONObject: [:])
			return iTunesAPIClient.Result.success((data, response))
		}
	}

	static var serverIssue: MockURLSession {
		return MockURLSession { url in
			let response = HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)
			return iTunesAPIClient.Result.success((nil, response))
		}
	}

	static var invalidResponse: MockURLSession {
		return MockURLSession { _ in
			return iTunesAPIClient.Result.failure(.unknown)
		}
	}

	static var invalidJSON: MockURLSession {
		return MockURLSession { url in
			let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
			let data = Data(capacity: 8)
			return iTunesAPIClient.Result.success((data, response))
		}
	}
}
