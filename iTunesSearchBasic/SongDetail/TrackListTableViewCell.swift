//
//  TrackListTableViewCell.swift
//  iTunesSearchBasic
//
//  Created by Charles Moncada on 27/09/18.
//  Copyright © 2018 Charles Moncada. All rights reserved.
//

import UIKit

protocol TrackListTableViewCellDelegate: class {
	func playTrack(with url: String?)
}

class TrackListTableViewCell: UITableViewCell {

	@IBOutlet weak var songNameLabel: UILabel!
	weak var delegate: TrackListTableViewCellDelegate?

	var previewURL: String?

	override func prepareForReuse() {
		songNameLabel.text = nil
		delegate = nil
		previewURL = nil
	}

	func configure(with song: Song, at index: Int) {
		self.songNameLabel.text = "Pista \(index + 1): \(song.trackName ?? "")"
		self.previewURL = song.previewUrl
	}

	@IBAction func playButtonPressed(_ sender: Any) {
		delegate?.playTrack(with: previewURL)
	}
}
