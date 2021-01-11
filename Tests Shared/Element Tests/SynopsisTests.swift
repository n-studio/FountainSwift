//
//  SynopsisTests.m
//  Fountain
//
//  Copyright (c) 2013 Nima Yousefi & John August
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//

import Foundation
import XCTest
@testable import FountainSwift

class SynopsisTests: BaseElementTests {
    override func setUp() {
        super.setUp()
        self.loadTestFile("Synopses")
}

    // MARK: - Tests

    func testSynopsis() {
        let index = 1
        XCTAssertEqual(self.elementType(at: index), "Synopsis", self.errorForElement(at: index))
    }

    func testSynopsisWithoutSpaceBetweenMarkAndText() {
        let index = 3
        XCTAssertEqual(self.elementType(at: index), "Synopsis", self.errorForElement(at: index))
    }

    func testAllCapsSynopsis() {
        let index = 5
        XCTAssertEqual(self.elementType(at: index), "Synopsis", self.errorForElement(at: index))
    }
}
