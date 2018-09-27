//
//  SongDetailViewController.swift
//  iTunesSearchBasic
//
//  Created by Charles Moncada on 27/09/18.
//  Copyright © 2018 Charles Moncada. All rights reserved.
//

import UIKit
import Kingfisher
import AVFoundation

// MARK:- SongDetailView protocol

protocol SongDetailView: class {
	func reloadData()
	func display(_ error: Error)
}

// MARK:- SongDetailViewController

class SongDetailViewController: UIViewController {

	// MARK: IBOutlets

	@IBOutlet weak var albumNameLabel: UILabel!
	@IBOutlet weak var artistNameLabel: UILabel!
	@IBOutlet weak var albumCoverImageView: UIImageView!
	@IBOutlet weak var songListTableView: UITableView!

	// MARK: Properties

	var song: Song!
	var presenter: SongDetailPresenter!
	let cellIdentifier = "TrackListTableViewCell"
	private var player: AVPlayer?

	// MARK: Lifecycle

	override func viewDidLoad() {
		configure(with: song)
		title = "Detalle"
		presenter.fetchSongList(with: song.collectionId)
	}

	// MARK: Helper method

	private func configure(with song: Song) {
		albumNameLabel.text = song.collectionName
		artistNameLabel.text = song.artistName
		let url = URL(string: song.artworkUrl100)
		albumCoverImageView.kf.setImage(with: url)
	}
}

// MARK:- SongDetailView protocol implementation

extension SongDetailViewController: SongDetailView {
	func reloadData() {
		songListTableView.reloadData()
	}

	func display(_ error: Error) {
		
	}
}

// MARK:- UITableViewDataSource

extension SongDetailViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return presenter.tracksCount
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! TrackListTableViewCell
		cell.delegate = self

		let song = presenter.song(at: indexPath.row)
		cell.configure(with: song, at: indexPath.row)
		return cell
	}
}

// MARK:- UITableViewDelegate

extension SongDetailViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}
}

// MARK:- TrackListTableViewCellDelegate

extension SongDetailViewController: TrackListTableViewCellDelegate {
	func playTrack(with urlString: String?) {
		guard
			let urlString = urlString,
			let url  = URL.init(string: urlString)
		else { return }

		player?.pause()
		let playerItem: AVPlayerItem = AVPlayerItem(url: url)
		player = AVPlayer(playerItem: playerItem)
		player?.play()
	}
}
