//
//  ResultTest.swift
//  iTunesSearchBasicTests
//
//  Created by Charles Moncada on 27/09/18.
//  Copyright © 2018 Charles Moncada. All rights reserved.
//

import XCTest
@testable import iTunesSearchBasic

class ResultTests: XCTestCase {

	func testSuccess() {
		let result = iTunesAPIClient.Result<Int, Int>.success(1)
		XCTAssertEqual(result.value, 1)
		XCTAssertNil(result.error)
	}

	func testFailure() {
		let result = iTunesAPIClient.Result<Int, Int>.failure(0)
		XCTAssertNil(result.value)
		XCTAssertEqual(result.error, 0)
	}

}
