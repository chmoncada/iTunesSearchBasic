//
//  iTunesAPIClientTests.swift
//  iTunesSearchBasicTests
//
//  Created by Charles Moncada on 27/09/18.
//  Copyright © 2018 Charles Moncada. All rights reserved.
//

import XCTest
@testable import iTunesSearchBasic

class iTunesAPIClientTests: XCTestCase {

	func testInit_DefaultValues() {
		let itunes = iTunesAPIClient()
		XCTAssertFalse(itunes.isDebug)
	}

	func testInit_DebugTrue() {
		let itunes = iTunesAPIClient(debug: true)
		XCTAssertTrue(itunes.isDebug)
	}

	func testBasicSearch() {
		let session = MockURLSession.empty

		let client = iTunesAPIClient(session: session, debug: true)
		client.search(for: "REM") { _ in }

		XCTAssertEqual(session.completedURLs.first!.absoluteString, "https://itunes.apple.com/search?media=music&entity=song&term=REM&offset=0&limit=20")
	}

	func testBasicSearchWithEscapingCharacters() {
		let session = MockURLSession.empty

		let client = iTunesAPIClient(session: session, debug: true)
		client.search(for: "Man of the Moon") { _ in }

		XCTAssertEqual(session.completedURLs.first!.absoluteString, "https://itunes.apple.com/search?media=music&entity=song&term=Man%20of%20the%20Moon&offset=0&limit=20")
	}

	func testBasicSearchWithPaging() {
		let session = MockURLSession.empty

		let client = iTunesAPIClient(session: session, debug: true)
		client.search(for: "REM", page: 2) { _ in }

		XCTAssertEqual(session.completedURLs.first!.absoluteString, "https://itunes.apple.com/search?media=music&entity=song&term=REM&offset=20&limit=20")
	}

	func testFetchSongList() {
		let session = MockURLSession.empty

		let client = iTunesAPIClient(session: session, debug: true)
		let collectionID = 1234
		client.fetchSongList(for: collectionID) { _ in }

		XCTAssertEqual(session.completedURLs.first!.absoluteString, "https://itunes.apple.com/lookup?id=1234&entity=song")
	}

	func testSearch_withServerIssue() {
		let session = MockURLSession.serverIssue

		let client = iTunesAPIClient(session: session, debug: true)
		client.search(for: "Losing My Religion") { _ in }

		XCTAssertEqual(session.completedURLs.first!.absoluteString, "https://itunes.apple.com/search?media=music&entity=song&term=Losing%20My%20Religion&offset=0&limit=20")
	}

	func testSearch_withUnknownResponse() {
		let session = MockURLSession.invalidResponse

		let client = iTunesAPIClient(session: session, debug: true)
		client.search(for: "Nightswimming") { _ in }

		XCTAssertEqual(session.completedURLs.first!.absoluteString, "https://itunes.apple.com/search?media=music&entity=song&term=Nightswimming&offset=0&limit=20")
	}

	func testSearch_withInvalidJSON() {
		let session = MockURLSession.invalidJSON

		let client = iTunesAPIClient(session: session, debug: true)
		client.search(for: "Stand") { _ in }

		XCTAssertEqual(session.completedURLs.first!.absoluteString, "https://itunes.apple.com/search?media=music&entity=song&term=Stand&offset=0&limit=20")
	}

	func testSearch_withMissingData() {
		let session = MockURLSession { (url) -> (iTunesAPIClient.Result<(Data?, URLResponse?), iTunesAPIClient.Error>) in
			let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
			return (iTunesAPIClient.Result.success((nil, response)))
		}

		let client = iTunesAPIClient(session: session, debug: true)
		client.search(for: "Drive") { _ in }

		XCTAssertEqual(session.completedURLs.first!.absoluteString, "https://itunes.apple.com/search?media=music&entity=song&term=Drive&offset=0&limit=20")
	}

}
