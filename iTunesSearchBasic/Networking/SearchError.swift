//
//  SearchError.swift
//  iTunesSearchBasic
//
//  Created by Charles Moncada on 27/09/18.
//  Copyright © 2018 Charles Moncada. All rights reserved.
//

import Foundation

extension iTunesAPIClient {
	enum Error: Swift.Error {
		case unknown
		case invalidSearchTerm
		case invalidURL
		case invalidServerResponse
		case serverError(Int)
		case missingData
		case invalidJSON(Swift.Error)
		case invalidJSONStructure
	}
}
