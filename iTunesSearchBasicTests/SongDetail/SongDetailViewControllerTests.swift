//
//  SongDetailViewControllerTests.swift
//  iTunesSearchBasicTests
//
//  Created by Charles Moncada on 27/09/18.
//  Copyright © 2018 Charles Moncada. All rights reserved.
//

import XCTest
@testable import iTunesSearchBasic

class SongDetailViewControllerTests: XCTestCase {

	var window: UIWindow!
	var sut: SongDetailViewController!
	var mockPresenter: MockSongDetailPresenter!

	override func setUp() {
		super.setUp()
		window = UIWindow()
		setupSongDetailViewController()
	}

	override func tearDown() {
		super.tearDown()
	}

	func setupSongDetailViewController() {
		mockPresenter = MockSongDetailPresenter()

		let bundle = Bundle.main
		let storyboard = UIStoryboard(name: "Main", bundle: bundle)
		sut = storyboard.instantiateViewController(withIdentifier: "SongDetailViewController") as? SongDetailViewController

		let song = Song(artistName: "REM", collectionName: "Out Of Time", collectionId: 1234, trackName: "Shinny Happy People", artworkUrl100: "https://empty.com", previewUrl: nil)
		sut.song = song
		sut.presenter = mockPresenter
	}

	func loadView() {
		window.addSubview(sut.view)
		RunLoop.current.run(until: Date())
	}

	func testIfViewDidLoad() {
		loadView()
		XCTAssertEqual(sut.title, "Detalle")
	}

	func testTableViewNumberOfRows() {
		loadView()

		let rows = sut.tableView(sut.songListTableView, numberOfRowsInSection: 0)

		XCTAssertEqual(2, rows)
	}

	func testTableViewCellConfigWithProperSong() {
		loadView()

		let indexPath = IndexPath(row: 0, section: 0)
		let cell = sut.tableView(sut.songListTableView, cellForRowAt: indexPath) as! TrackListTableViewCell

		XCTAssertEqual(cell.songNameLabel.text, "Pista 1: Shinny Happy People")
	}

	func testTableViewCellDeselectAfterSelect() {
		loadView()
		let indexPath = IndexPath(row: 0, section: 0)
		sut.tableView(sut.songListTableView, didSelectRowAt: indexPath)

		XCTAssertFalse(sut.songListTableView.indexPathsForSelectedRows?.contains(indexPath) ?? false)

	}
}

extension SongDetailViewControllerTests {
	class MockSongDetailPresenter: SongDetailPresenterProtocol {

		var albumTracks: [Song] = []

		var tracksCount: Int {
			return albumTracks.count
		}

		func song(at index: Int) -> Song {
			return albumTracks[index]
		}

		func fetchSongList(with id: Int) {
			let song1 = Song(artistName: "REM", collectionName: "Out Of Time", collectionId: 1234, trackName: "Shinny Happy People", artworkUrl100: "https://empty.com", previewUrl: nil)
			let song2 = Song(artistName: "REM", collectionName: "Out Of Time", collectionId: 1234, trackName: "Losing My Religion", artworkUrl100: "https://empty.com", previewUrl: nil)
			let songs = [song1, song2]
			albumTracks = songs
		}

	}
}
