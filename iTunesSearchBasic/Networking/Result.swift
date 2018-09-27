//
//  Result.swift
//  iTunesSearchBasic
//
//  Created by Charles Moncada on 27/09/18.
//  Copyright © 2018 Charles Moncada. All rights reserved.
//

import Foundation

extension iTunesAPIClient {
	enum Result<T, U> {
		case success(T)
		case failure(U)

		var value: T? {
			if case .success(let value) = self {
				return value
			}
			return nil
		}

		var error: U? {
			if case .failure(let error) = self {
				return error
			}
			return nil
		}
	}
}
