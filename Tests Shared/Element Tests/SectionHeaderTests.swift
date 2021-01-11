//
//  SectionHeaderTests.m
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

class SectionHeaderTests: BaseElementTests {
    override func setUp() {
        super.setUp()
        self.loadTestFile("SectionHeaders")
    }

    // MARK: - Tests

    func testSectionHeader() {
        let index = 0
        XCTAssertEqual(self.elementType(at: index), "Section Heading", self.errorForElement(at: index))
    }

    func testNoSpaceBetweenHashAndHeader() {
        let index = 1
        XCTAssertEqual(self.elementType(at: index), "Section Heading", self.errorForElement(at: index))
    }

    func testAllCapsNoSpace() {
        let index = 2
        XCTAssertEqual(self.elementType(at: index), "Section Heading", self.errorForElement(at: index))
    }

    func testAllCaps() {
        let index = 3
        XCTAssertEqual(self.elementType(at: index), "Section Heading", self.errorForElement(at: index))
    }

    func testNumberOnly() {
        let index = 4
        XCTAssertEqual(self.elementType(at: index), "Section Heading", self.errorForElement(at: index))
    }

    func testSectionDepth() {
        var index = 5
        XCTAssertEqual(self.elementType(at: index), "Section Heading", self.errorForElement(at: index))
        XCTAssertEqual(self.sectionDepthOfElement(at: index), 2, self.errorForElement(at: index))

        index = 6
        XCTAssertEqual(self.elementType(at: index), "Section Heading", self.errorForElement(at: index))
        XCTAssertEqual(self.sectionDepthOfElement(at: index), 3, self.errorForElement(at: index))
    }
}
