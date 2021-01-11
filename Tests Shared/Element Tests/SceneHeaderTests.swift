//
//  FTNSceneHeaderTests.m
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

class SceneHeaderTests: BaseElementTests {
    override func setUp() {
        super.setUp()
        self.loadTestFile("SceneHeaders")
    }

    // MARK: - Tests

    func testInt() {
        let index = 0
        XCTAssertEqual(self.elementType(at: index), "Scene Heading", self.errorForElement(at: index))
    }

    func testExt() {
        let index = 1
        XCTAssertEqual(self.elementType(at: index), "Scene Heading", self.errorForElement(at: index))
    }

    func testSpaceSeparators() {
        var index = 2
        XCTAssertEqual(self.elementType(at: index), "Scene Heading", self.errorForElement(at: index))

        index = 3
        XCTAssertEqual(self.elementType(at: index), "Scene Heading", self.errorForElement(at: index))
    }

    func testIntExt() {
        let index = 4
        XCTAssertEqual(self.elementType(at: index), "Scene Heading", self.errorForElement(at: index))
    }

    func testAbbreviatedIntExt() {
        var index = 6
        XCTAssertEqual(self.elementType(at: index), "Scene Heading", self.errorForElement(at: index))

        index = 7
        XCTAssertEqual(self.elementType(at: index), "Scene Heading", self.errorForElement(at: index))

        index = 8
        XCTAssertEqual(self.elementType(at: index), "Scene Heading", self.errorForElement(at: index))
    }

    func testESTHeader() {
        var index = 11
        XCTAssertEqual(self.elementType(at: index), "Scene Heading", self.errorForElement(at: index))

        index = 12
        XCTAssertEqual(self.elementType(at: index), "Scene Heading", self.errorForElement(at: index))
    }

    func testSceneHeaderWithDate() {
        let index = 13
        XCTAssertEqual(self.elementType(at: index), "Scene Heading", self.errorForElement(at: index))
    }

    func testForcedSceneHeader() {
        let index = 14
        XCTAssertEqual(self.elementType(at: index), "Scene Heading", self.errorForElement(at: index))
    }

    func testNotAForcedSceneHeader() {
        let index = 15
        XCTAssertFalse(self.elementType(at: index) == "Scene Heading", self.errorForElement(at: index))
    }

    func testRequiresBlankLinesBeforeAndAfter() {
        let index = 16
        XCTAssertFalse(self.elementType(at: index) == "Scene Heading", self.errorForElement(at: index))
    }

    func testNeedsSeparatorAfterPrefix() {
        let index = 17
        XCTAssertFalse(self.elementType(at: index) == "Scene Heading", self.errorForElement(at: index))
    }

    func testNoCaps() {
        let index = 18
        XCTAssertTrue(self.elementType(at: index) == "Scene Heading", self.errorForElement(at: index))
    }
}
