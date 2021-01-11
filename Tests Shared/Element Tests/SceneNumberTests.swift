//
//  SceneNumberTests.m
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

class SceneNumberTests: BaseElementTests {
    override func setUp() {
        super.setUp()
        self.loadTestFile("SceneNumbers")
    }

    // MARK: - Tests

    func testNumber() {
        let index = 0
        let expectedText = "1"

        XCTAssertEqual(self.elementType(at: index), "Scene Heading", self.errorForElement(at: index))
        XCTAssertEqual(self.elementText(at: index), "INT. HOUSE - DAY ", self.errorForElement(at: index))
        XCTAssertEqual(self.sceneNumberForElement(at: index), expectedText, self.errorForElement(at: index))
    }

    func testNumberAndLetter() {
        let index = 1
        let expectedText = "1A"

        XCTAssertEqual(self.elementType(at: index), "Scene Heading", self.errorForElement(at: index))
        XCTAssertEqual(self.elementText(at: index), "INT. HOUSE - DAY ", self.errorForElement(at: index))
        XCTAssertEqual(self.sceneNumberForElement(at: index), expectedText, self.errorForElement(at: index))
    }

    func testNumberAndLowercaseLetter() {
        let index = 2
        let expectedText = "1a"

        XCTAssertEqual(self.elementType(at: index), "Scene Heading", self.errorForElement(at: index))
        XCTAssertEqual(self.elementText(at: index), "INT. HOUSE - DAY ", self.errorForElement(at: index))
        XCTAssertEqual(self.sceneNumberForElement(at: index), expectedText, self.errorForElement(at: index))
    }

    func testLetterAndNumber() {
        let index = 3
        let expectedText = "A1"

        XCTAssertEqual(self.elementType(at: index), "Scene Heading", self.errorForElement(at: index))
        XCTAssertEqual(self.elementText(at: index), "INT. HOUSE - DAY ", self.errorForElement(at: index))
        XCTAssertEqual(self.sceneNumberForElement(at: index), expectedText, self.errorForElement(at: index))
    }

    func testDashes() {
        let index = 4
        let expectedText = "I-1-A"

        XCTAssertEqual(self.elementType(at: index), "Scene Heading", self.errorForElement(at: index))
        XCTAssertEqual(self.elementText(at: index), "INT. HOUSE - DAY ", self.errorForElement(at: index))
        XCTAssertEqual(self.sceneNumberForElement(at: index), expectedText, self.errorForElement(at: index))
    }

    func testNumberWithPeriod() {
        let index = 5
        let expectedText = "1."

        XCTAssertEqual(self.elementType(at: index), "Scene Heading", self.errorForElement(at: index))
        XCTAssertEqual(self.elementText(at: index), "INT. HOUSE - DAY ", self.errorForElement(at: index))
        XCTAssertEqual(self.sceneNumberForElement(at: index), expectedText, self.errorForElement(at: index))
    }

    func testSceneHeaderWithExtraInfo() {
        let index = 6
        let expectedText = "110A"

        XCTAssertEqual(self.elementType(at: index), "Scene Heading", self.errorForElement(at: index))
        XCTAssertEqual(self.elementText(at: index), "INT. HOUSE - DAY - FLASHBACK (1944) ", self.errorForElement(at: index))
        XCTAssertEqual(self.sceneNumberForElement(at: index), expectedText, self.errorForElement(at: index))
    }
}
