//
//  SongDetailPresenterTests.swift
//  iTunesSearchBasicTests
//
//  Created by Charles Moncada on 27/09/18.
//  Copyright © 2018 Charles Moncada. All rights reserved.
//

import XCTest
@testable import iTunesSearchBasic

class SongDetailPresenterTests: XCTestCase {

	var sut: SongDetailPresenter!
	var mockView: MockSongDetailView!

	override func setUp() {
		super.setUp()
		setupSongDetailPresenter()
	}

	override func tearDown() {
		super.tearDown()
	}

	func setupSongDetailPresenter() {
		mockView = MockSongDetailView()
		sut = SongDetailPresenter(view: mockView, apiClient: MockiTunesAPIClient())
	}

	func testTracksCountCorrect() {

		sut.fetchSongList(with: 123)

		XCTAssertEqual(2, sut.tracksCount)
	}

	func testCorrectSongAtIndex() {
		sut.fetchSongList(with: 123)
		let song1 = Song(artistName: "REM", collectionName: "Out Of Time", collectionId: 1234, trackName: "Shinny Happy People", artworkUrl100: "https://empty.com", previewUrl: nil)
		XCTAssertEqual(song1, sut.song(at: 0))
	}

	func testSearchWithNoResults() {
		sut.fetchSongList(with: 999)
		XCTAssertEqual(0, sut.tracksCount)
	}

	func testSendingViewReloadData() {
		sut.fetchSongList(with: 123)

		XCTAssertTrue(mockView.isReloadingData)
	}
}

extension SongDetailPresenterTests {
	class MockSongDetailView: SongDetailView {

		private(set) var isReloadingData = false
		func reloadData() {
			isReloadingData = true
		}

		private(set) var isDisplayingError = false
		func display(_ error: Error) {
			isDisplayingError = true
		}

	}

	class MockiTunesAPIClient: iTunesAPIClientProtocol {
		func search(for term: String, page: Int, completion: @escaping (iTunesAPIClient.Result<iTunesSearchResponse, iTunesAPIClient.Error>) -> Void) {
			let response = iTunesSearchResponse(resultCount: 0, results: [])
			completion(.success(response))
		}

		func fetchSongList(for collectionId: Int, completion: @escaping (iTunesAPIClient.Result<iTunesSearchResponse, iTunesAPIClient.Error>) -> Void) {

			let response: iTunesSearchResponse
			if collectionId == 123 {
				let fakeAlbum = Song(artistName: "REM", collectionName: "Out Of Time", collectionId: 1234, trackName: nil, artworkUrl100: "https://empty.com", previewUrl: nil)
				let song1 = Song(artistName: "REM", collectionName: "Out Of Time", collectionId: 1234, trackName: "Shinny Happy People", artworkUrl100: "https://empty.com", previewUrl: nil)
				let song2 = Song(artistName: "REM", collectionName: "Out Of Time", collectionId: 1234, trackName: "Losing My Religion", artworkUrl100: "https://empty.com", previewUrl: nil)
				let songs = [fakeAlbum, song1, song2]
				response = iTunesSearchResponse(resultCount: songs.count, results: songs)
			} else {
				response = iTunesSearchResponse(resultCount: 0, results: [])
			}

			completion(.success(response))
		}
	}
}
