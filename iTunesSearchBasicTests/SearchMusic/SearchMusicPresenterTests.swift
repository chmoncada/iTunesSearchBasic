//
//  SearchMusicPresenterTests.swift
//  iTunesSearchBasicTests
//
//  Created by Charles Moncada on 27/09/18.
//  Copyright © 2018 Charles Moncada. All rights reserved.
//

import XCTest
@testable import iTunesSearchBasic

class SearchMusicPresenterTests: XCTestCase {

	var sut: SearchMusicPresenter!

	override func setUp() {
		super.setUp()
		setupSearchMusicPresenter()
		sut.fetchSongs(with: "result")
	}

	override func tearDown() {
		super.tearDown()
	}

	func setupSearchMusicPresenter() {
		sut = SearchMusicPresenter(view: MockSearchView(), apiClient: MockiTunesAPIClient())
	}

	func testCurrentCountCorrec() {
		XCTAssertEqual(2, sut.currentCount)
	}

	func testCorrectSongAtIndex() {
		let song1 = Song(artistName: "REM", collectionName: "Out Of Time", collectionId: 1234, trackName: "Shinny Happy People", artworkUrl100: "https://empty.com", previewUrl: nil)
		XCTAssertEqual(song1, sut.song(at: 0))
	}

	func testClearResults() {
		sut.clearResults()
		XCTAssertEqual(0, sut.currentCount)
	}

	func testSearchWithNoResults() {
		sut.fetchSongs(with: "empty")
		XCTAssertEqual(0, sut.currentCount)
	}

}

extension SearchMusicPresenterTests {
	class MockSearchView: SearchMusicView {

		private(set) var isLoading = false
		func startLoading() {
			isLoading = true
		}

		func stopLoading() {
			isLoading = false
		}

		func display(_ error: Error) {
			//
		}

		func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?) {
			//
		}

		func reloadData() {
			//
		}

		func setNoResultsMessage() {
			//
		}
	}

	class MockiTunesAPIClient: iTunesAPIClientProtocol {
		func search(for term: String, page: Int, completion: @escaping (iTunesAPIClient.Result<iTunesSearchResponse, iTunesAPIClient.Error>) -> Void) {

			let response: iTunesSearchResponse
			if term == "result" {
				let song1 = Song(artistName: "REM", collectionName: "Out Of Time", collectionId: 1234, trackName: "Shinny Happy People", artworkUrl100: "https://empty.com", previewUrl: nil)
				let song2 = Song(artistName: "REM", collectionName: "Out Of Time", collectionId: 1234, trackName: "Losing My Religion", artworkUrl100: "https://empty.com", previewUrl: nil)
				let songs = [song1, song2]
				response = iTunesSearchResponse(resultCount: songs.count, results: songs)
			} else {
				response = iTunesSearchResponse(resultCount: 0, results: [])
			}

			completion(.success(response))
		}

		func fetchSongList(for collectionId: Int, completion: @escaping (iTunesAPIClient.Result<iTunesSearchResponse, iTunesAPIClient.Error>) -> Void) {
			let response = iTunesSearchResponse(resultCount: 0, results: [])
			completion(.success(response))
		}


	}
}
