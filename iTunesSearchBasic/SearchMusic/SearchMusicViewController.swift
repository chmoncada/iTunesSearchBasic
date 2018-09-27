//
//  SearchMusicViewController.swift
//  iTunesSearchBasic
//
//  Created by Charles Moncada on 27/09/18.
//  Copyright © 2018 Charles Moncada. All rights reserved.
//

import UIKit

// MARK:- SearchMusicView protocol

protocol SearchMusicView: class {
	func startLoading()
	func stopLoading()
	func display(_ error: Error)
	func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?)
	func reloadData()
	func setNoResultsMessage()
}

// MARK:- SearchMusicViewController

class SearchMusicViewController: UIViewController {

	// MARK: IBOutlets
	@IBOutlet weak var placeholderLabel: UILabel!
	@IBOutlet weak var songsTableView: UITableView!

	private let cellIdentifier = "SongResultTableViewCell"
	var presenter: SearchMusicPresenterProtocol!

	private weak var loadingView: UIActivityIndicatorView?
	private var searchTask: DispatchWorkItem?
	private var query: String?

	let transition = Animator()

	override func viewDidLoad() {
		navigationController?.navigationBar.prefersLargeTitles = true
		navigationController?.navigationItem.largeTitleDisplayMode = .always
		navigationController?.delegate = self

		configureSearchController()

		presenter = SearchMusicPresenter(view: self)

		songsTableView.isHidden = true
		placeholderLabel.isHidden = false
		placeholderLabel.text = "Puede buscar resultados usando la barra de búsqueda"
	}

	private func configureSearchController() {
		let search = UISearchController(searchResultsController: nil)
		search.searchResultsUpdater = self
		search.obscuresBackgroundDuringPresentation = false
		search.searchBar.placeholder = "Nombre de la canción o Artista"
		navigationItem.searchController = search
		navigationItem.hidesSearchBarWhenScrolling = false
		definesPresentationContext = true
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard segue.identifier == "songDetail" else { fatalError() }

		guard let detailVC = segue.destination as? SongDetailViewController else { fatalError() }

		let indexPath = songsTableView.indexPathForSelectedRow!
		detailVC.song = presenter.song(at: indexPath.row)
		detailVC.presenter = SongDetailPresenter(view: detailVC)
	}
}

// MARK:- SearchMusicView protocol implementation

extension SearchMusicViewController: SearchMusicView {
	func startLoading() {
		let loadingView = setupLoadingViewIfNeeded()
		loadingView.startAnimating()
		loadingView.alpha = 1
	}

	func stopLoading() {
		guard let loadingView = loadingView else { return }
		self.loadingView = nil

		UIView.animate(withDuration: 0.3, delay: 0, options: [.beginFromCurrentState], animations: { [weak loadingView] in
			loadingView?.alpha = 0
			}, completion: { (completed) in
				loadingView.removeFromSuperview()
		})
	}

	func display(_ error: Error) {
		print(error.localizedDescription)
	}

	func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?) {
		guard let newIndexPathsToReload = newIndexPathsToReload else {
			stopLoading()
			songsTableView.isHidden = false
			songsTableView.reloadData()
			return
		}
		let indexPathsToReload = visibleIndexPathsToReload(intersecting: newIndexPathsToReload)
		songsTableView.reloadRows(at: indexPathsToReload, with: .automatic)
	}

	func reloadData() {
		songsTableView.reloadData()
	}

	func setNoResultsMessage() {
		songsTableView.isHidden = true
		placeholderLabel.isHidden = false
		placeholderLabel.text = "No se encontraron resultados"
	}
}

// MARK:- Helper methods

extension SearchMusicViewController {

	// MARK: Pagination
	private func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
		let indexPathsForVisibleRows = songsTableView.indexPathsForVisibleRows ?? []
		let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
		return Array(indexPathsIntersection)
	}

	// MARK: Loading Indicator
	private func setupLoadingViewIfNeeded() -> UIActivityIndicatorView {
		if let loadingView = loadingView {
			return loadingView
		} else {
			let loadingView = UIActivityIndicatorView(style: .whiteLarge)

			loadingView.color = .black
			loadingView.translatesAutoresizingMaskIntoConstraints = false
			view.addSubview(loadingView)
			loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
			loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

			self.loadingView = loadingView
			return loadingView
		}
	}
}

// MARK:- UITableViewDataSource protocol

extension SearchMusicViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return presenter.currentCount
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SongResultTableViewCell
		let song = presenter.song(at: indexPath.row)
		cell.configure(with: song)
		return cell
	}
}

// MARK:- UITableViewDelegate protocol

extension SearchMusicViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 120
	}

	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let index = indexPath.row
		let maxIndex = tableView.numberOfRows(inSection: 0) - 4

		if let query = query, index == maxIndex {
			presenter.fetchSongs(with: query)
		}
	}
}

// MARK:- UISearchResultsUpdating protocol

extension SearchMusicViewController: UISearchResultsUpdating {
	func updateSearchResults(for searchController: UISearchController) {
		guard
			let text = searchController.searchBar.text,
			!text.isEmpty
		else {
			songsTableView.isHidden = true
			placeholderLabel.isHidden = false
			placeholderLabel.text = "Puede buscar resultados usando la barra de búsqueda"
			presenter.clearResults()
			return
		}

		searchTask?.cancel()
		let task = DispatchWorkItem { [weak self] in
			self?.query = text
			self?.placeholderLabel.isHidden = true
			self?.songsTableView.isHidden = false
			self?.presenter.fetchSongs(with: text)
		}
		self.searchTask = task

		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.75, execute: task)
	}
}

extension SearchMusicViewController: UINavigationControllerDelegate {
	func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

		guard operation == .push else { return nil }

		let indexPath = (songsTableView.indexPathsForSelectedRows?.first)!
		let cell = songsTableView.cellForRow(at: indexPath) as! SongResultTableViewCell
		transition.originFrame = cell.superview!.convert(cell.frame, to: nil)

		return transition
	}
}
