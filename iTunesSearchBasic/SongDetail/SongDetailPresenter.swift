//
//  SongDetailPresenter.swift
//  iTunesSearchBasic
//
//  Created by Charles Moncada on 27/09/18.
//  Copyright © 2018 Charles Moncada. All rights reserved.
//

import Foundation

// MARK:- SongDetailPresenterProtocol

protocol SongDetailPresenterProtocol {
	var tracksCount: Int { get }
	func song(at index: Int) -> Song
	func fetchSongList(with id: Int)
}

// MARK:- SongDetailPresenterProtocol

class SongDetailPresenter {
	typealias CollectionId = Int

	weak var view: SongDetailView?
	private let apiClient: iTunesAPIClient

	private var albumTracks: [Song] = [] {
		didSet {
			view?.reloadData()
		}
	}

	init(view: SongDetailView, apiClient: iTunesAPIClient = iTunesAPIClient()) {
		self.view = view
		self.apiClient = apiClient
	}
}

// MARK:- SongDetailPresenterProtocol implementation

extension SongDetailPresenter: SongDetailPresenterProtocol {
	var tracksCount: Int {
		return albumTracks.count
	}

	func song(at index: Int) -> Song {
		return albumTracks[index]
	}

	func fetchSongList(with id: CollectionId) {
		apiClient.fetchSongList(for: id) { [weak self] result in
			switch result {
			case .failure(let error):
				self?.view?.display(error)
			case .success(let response):
				guard !response.results.isEmpty else {
					return
				}

				let tracks = response.results.dropFirst() // First element is the collection info that is not needed
				self?.albumTracks = Array(tracks)
			}
		}
	}
}
