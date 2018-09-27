//
//  SearchMusicViewControllerTests.swift
//  iTunesSearchBasicTests
//
//  Created by Charles Moncada on 27/09/18.
//  Copyright © 2018 Charles Moncada. All rights reserved.
//

import XCTest
@testable import iTunesSearchBasic

class SearchMusicViewControllerTests: XCTestCase {

	var window: UIWindow!
	var sut: SearchMusicViewController!
	var mockPresenter: MockSearchMusicPresenter!

	override func setUp() {
		super.setUp()
		window = UIWindow()
		setupSongDetailViewController()
	}

	override func tearDown() {
		super.tearDown()
	}

	func setupSongDetailViewController() {
		mockPresenter = MockSearchMusicPresenter()

		let bundle = Bundle.main
		let storyboard = UIStoryboard(name: "Main", bundle: bundle)
		sut = storyboard.instantiateViewController(withIdentifier: "SearchMusicViewController") as? SearchMusicViewController

		sut.presenter = mockPresenter
	}

	func loadView() {
		window.addSubview(sut.view)
		sut.presenter = mockPresenter
		RunLoop.current.run(until: Date())
	}

	func testIfViewDidLoad() {
		loadView()

		let rows = sut.tableView(sut.songsTableView, numberOfRowsInSection: 0)

		XCTAssertEqual(0, rows)
		XCTAssertTrue(sut.songsTableView.isHidden)
	}

	func testTableViewNumberOfRows() {
		loadView()
		sut.presenter.fetchSongs(with: "test")

		let rows = sut.tableView(sut.songsTableView, numberOfRowsInSection: 0)

		XCTAssertEqual(2, rows)
	}

	func testTableViewCellConfigWithProperSong() {
		loadView()
		sut.presenter.fetchSongs(with: "test")
		sut.songsTableView.reloadData()

		let indexPath = IndexPath(row: 0, section: 0)
		let cell = sut.tableView(sut.songsTableView, cellForRowAt: indexPath) as! SongResultTableViewCell

		XCTAssertEqual(cell.songNameLabel.text, "Shinny Happy People")
	}

//	func testTableViewCellConfigWithProperSong() {
//		loadView()
//		sut.presenter.fetchSongs(with: "test")
//
//		let indexPath = IndexPath(row: 0, section: 0)
//		let cell = sut.tableView(sut.tableView, cellForRowAt: indexPath) as! SongResultTableViewCell
//
//		//XCTAssertEqual(cell.songNameLabel.text, "Shinny Happy People")
//	}

}

extension SearchMusicViewControllerTests {
	class MockSearchMusicPresenter: SearchMusicPresenterProtocol {

		var results: [Song] = []

		var currentCount: Int {
			return results.count
		}

		func fetchSongs(with query: String) {
			let song1 = Song(artistName: "REM", collectionName: "Out Of Time", collectionId: 1234, trackName: "Shinny Happy People", artworkUrl100: "https://empty.com", previewUrl: nil)
			let song2 = Song(artistName: "REM", collectionName: "Out Of Time", collectionId: 1234, trackName: "Losing My Religion", artworkUrl100: "https://empty.com", previewUrl: nil)
			let songs = [song1, song2]
			results = songs
		}

		func song(at index: Int) -> Song {
			return results[index]
		}

		func clearResults() {
			//
		}

	}
}
