//
//  SearchMusicPresenter.swift
//  iTunesSearchBasic
//
//  Created by Charles Moncada on 27/09/18.
//  Copyright © 2018 Charles Moncada. All rights reserved.
//

import Foundation

// MARK:- SearchMusicPresenterProtocol

protocol SearchMusicPresenterProtocol {
	var currentCount: Int { get }
	func fetchSongs(with query: String)
	func song(at index: Int) -> Song
	func clearResults()
}

// MARK:- SearchMusicPresenter

class SearchMusicPresenter: SearchMusicPresenterProtocol {

	weak var view: SearchMusicView?
	private let apiClient: iTunesAPIClientProtocol

	// MARK: Private parameters
	private var isSearchInProgress = false
	private var currentPage = 1
	private var currentQuery: String? = nil
	private var songs: [Song] = [] {
		didSet {
			view?.reloadData()
		}
	}

	// MARK: Init

	init(view: SearchMusicView, apiClient: iTunesAPIClientProtocol = iTunesAPIClient()) {
		self.view = view
		self.apiClient = apiClient
	}

	// MARK: SearchMusicPresenterProtocol

	var currentCount: Int {
		return songs.count
	}

	func song(at index: Int) -> Song {
		return songs[index]
	}

	func fetchSongs(with query: String) {

		guard !isSearchInProgress else { return }

		if query != currentQuery {
			currentQuery = query
			songs = []
			currentPage = 1
		}

		view?.startLoading()
		isSearchInProgress = true

		apiClient.search(for: query, page: currentPage) { [weak self] (result) in
			switch result {
			case .failure(let error):
				self?.isSearchInProgress = false
				self?.view?.display(error)
			case .success(let response):
				self?.isSearchInProgress = false
				self?.view?.stopLoading()

				guard !response.results.isEmpty else {
					guard self?.currentPage == 1 else {
						return
					}
					self?.view?.setNoResultsMessage()
					self?.songs = []
					self?.currentPage = 1
					return
				}

				self?.songs.append(contentsOf: response.results)

				if let currentPage = self?.currentPage, currentPage > 1 {
					let indexPathsToReload = self?.calculateIndexPathsToReload(from: response.results)
					self?.view?.onFetchCompleted(with: indexPathsToReload)
				} else {
					self?.view?.onFetchCompleted(with: .none)
				}

				self?.currentPage += 1
			}
		}
	}

	func clearResults() {
		songs = []
	}

	// MARK: Helper methods

	private func calculateIndexPathsToReload(from newSongs: [Song]) -> [IndexPath] {
		let startIndex = songs.count - newSongs.count
		let endIndex = startIndex + newSongs.count
		return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
	}
}
