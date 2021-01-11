//
//  BrickAndSteelTests.m
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

class BrickAndSteelTests: XCTestCase {
    var script: FNScript!

    override func setUp() {
        super.setUp()
        let bundle = Bundle(for: BigFishTests.self)
        let path = bundle.path(forResource: "Brick And Steel", ofType: "txt")!
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
        let indexes = [0, 23, 32, 40, 49, 55]

        for index in indexes {
            let element = self.script.elements[index]
            XCTAssertEqual(element.elementType, "Scene Heading", "Index \(index): [\(element.elementType))] \(element.elementText ))")
        }
    }

    func testCharacters() {
        let indexes = [3, 5, 18, 20, 25]

        for index in indexes {
            let element = self.script.elements[index]
            XCTAssertEqual(element.elementType, "Character", "Index \(index): [\(element.elementType))] \(element.elementText))")
        }
    }

    func testDialogues() {
        let indexes = [4, 12, 27]

        for index in indexes {
            let element = self.script.elements[index]
            XCTAssertEqual(element.elementType, "Dialogue", "Index \(index): [\(element.elementType))] \(element.elementText))")
        }
    }

    func testParentheticals() {
        let indexes = [11, 26]

        for index in indexes {
            let element = self.script.elements[index]
            XCTAssertEqual(element.elementType, "Parenthetical", "Index \(index): [\(element.elementType))] \(element.elementText))")
        }
    }

    func testTransitions() {
        let indexes = [22, 31, 68, 77]

        for index in indexes {
            let element = self.script.elements[index]
            XCTAssertEqual(element.elementType, "Transition", "Index \(index): [\(element.elementType))] \(element.elementText ))")
        }
    }

    func testActions() {
        let indexes = [1, 16, 30, 52]

        for index in indexes {
            let element = self.script.elements[index]
            XCTAssertEqual(element.elementType, "Action", "Index \(index): [\(element.elementType))] \(element.elementText))")
        }
    }

    func testCenteredElements() {
        let indexes = [50, 51]

        for index in indexes {
            let element = self.script.elements[index]
            XCTAssertTrue(element.isCentered, "Index \(index): [\(element.elementType))] \(element.elementText))");
        }
    }

    func testDualDialogue() {
        let indexes = [18, 20]

        for index in indexes {
            let element = self.script.elements[index]
            XCTAssertTrue(element.isDualDialogue, "Index \(index): [\(element.elementType))] \(element.elementText))")
        }
    }

    func testPreserveSpaces() {
        let expectedString = "    *Did you know Brick and Steel are retired?*"
        let element = self.script.elements[27]
        XCTAssertEqual(element.elementText, expectedString)
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
        let expectedCount = 2
        XCTAssertEqual(actualCount, expectedCount)
    }
}
