//
//  Song.swift
//  iTunesSearchBasic
//
//  Created by Charles Moncada on 27/09/18.
//  Copyright © 2018 Charles Moncada. All rights reserved.
//

import Foundation

struct Song: Codable, Equatable {
	let artistName: String
	let collectionName: String
	let collectionId: Int
	let trackName: String?
	let artworkUrl100: String
	let previewUrl: String?
}
