//
//  SongResultTableViewCell.swift
//  iTunesSearchBasic
//
//  Created by Charles Moncada on 27/09/18.
//  Copyright © 2018 Charles Moncada. All rights reserved.
//

import UIKit
import Kingfisher

class SongResultTableViewCell: UITableViewCell {

	@IBOutlet weak var coverImageView: UIImageView!
	@IBOutlet weak var songNameLabel: UILabel!
	@IBOutlet weak var authorNameLabel: UILabel!

	override func prepareForReuse() {
		coverImageView.image = UIImage(named: "album-art-placeholder.png")
		songNameLabel.text = nil
		authorNameLabel.text = nil
	}

	func configure(with song: Song) {
		self.songNameLabel.text = song.trackName
		self.authorNameLabel.text = song.artistName
		let url = URL(string: song.artworkUrl100)
		self.coverImageView.kf.setImage(with: url)
	}

}
