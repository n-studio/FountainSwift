//
//  BigFishTests.m
//
//  Copyright (c) 2012 Nima Yousefi & John August
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

class BigFishTests: XCTestCase {
    var script: FNScript!

    override func setUp() {
        super.setUp()
        let bundle = Bundle(for: BigFishTests.self)
        let path = bundle.path(forResource: "Big Fish", ofType: "fountain")!
        self.script = FNScript(file: path)
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: - Body tests

    func testScriptLoading() {
        XCTAssertNotNil(self.script, "The script wasn't able to load.")
    }

    func testSceneHeadings() {
        let indexes = [11, 17, 31, 50]
        for index in indexes {
            let element = self.script.elements[index]

            XCTAssertEqual(element.elementType, "Scene Heading", "Index \(index): [\(element.elementType ?? ""))] \(element.elementText ?? ""))")
        }
    }

    func testCharacters() {
        let indexes = [6, 9, 13, 19, 39]
        for index in indexes {
            let element = self.script.elements[index]
            XCTAssertEqual(element.elementType, "Character", "Index \(index): [\(element.elementType ?? ""))] \(element.elementText ?? ""))")
        }
    }

    func testDialogues() {
        let indexes = [7, 10, 14, 16, 20, 24]

        for index in indexes {
            let element = self.script.elements[index]
            XCTAssertEqual(element.elementType, "Dialogue", "Index \(index): [\(element.elementType ?? ""))] \(element.elementText ?? ""))")
        }
    }

    func testParentheticals() {
        let indexes = [15, 23, 40, 70]

        for index in indexes {
            let element = self.script.elements[index]
            XCTAssertEqual(element.elementType, "Parenthetical", "Index \(index): [\(element.elementType ?? ""))] \(element.elementText ?? ""))")
        }
    }

    func testTransitions() {
        let indexes = [209]

        for index in indexes {
            let element = self.script.elements[index]
            XCTAssertEqual(element.elementType, "Transition", "Index \(index): [\(element.elementType ?? ""))] \(element.elementText ?? ""))")
        }
    }

    func testPageBreaks() {
        let indexes = [1]

        for index in indexes {
            let element = self.script.elements[index]
            XCTAssertEqual(element.elementType, "Page Break", "Index \(index): [\(element.elementType ?? ""))] \(element.elementText ?? ""))")
        }
    }

    func testActions() {
        let indexes = [0, 3, 38]

        for index in indexes {
            let element = self.script.elements[index]
            XCTAssertEqual(element.elementType, "Action", "Index \(index): [\(element.elementType ?? ""))] \(element.elementText ?? ""))")
        }
    }

    // MARK: - Title page tests

    func testTitlePage() {
        let numberOfTitlePageElements = self.script.titlePage.count
        let expectedNumberOfElements = 6
        XCTAssertEqual(expectedNumberOfElements, numberOfTitlePageElements)
    }

    func testTitle() {
        let title = self.script.titlePage[0]["title"]
        let actualCount = title?.count
        let expectedCount = 1
        XCTAssertEqual(actualCount, expectedCount)

        let titleValue = title?[0]
        XCTAssertEqual(titleValue, "Big Fish")
    }

    func testCredit() {
        let credit = self.script.titlePage[1]["credit"]
        let actualCount = credit?.count
        let expectedCount = 1
        XCTAssertEqual(actualCount, expectedCount)

        let creditValue = credit?[0]
        XCTAssertEqual(creditValue, "written by")
    }

    func testNotes() {
        let notes = self.script.titlePage[4]["notes"]
        let actualCount = notes?.count
        let expectedCount = 3
        XCTAssertEqual(actualCount, expectedCount)

        let noteValue = notes?[0]
        XCTAssertEqual(noteValue, "FINAL PRODUCTION DRAFT")
    }

    static var allTests = [
        ("testScriptLoading", testScriptLoading),
    ]
}
