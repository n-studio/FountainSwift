//
//  FTNParsingElementsTests.m
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

class BaseElementTests: XCTestCase {
    var elements: [FNElement] = []

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: - Helpers

    func pathForFile(_ filename: String) -> String {
        let bundle = Bundle(for: BigFishTests.self)
        let path = bundle.path(forResource: filename, ofType: "fountain")!

        return path
    }

    func loadTestFile(_ filename: String) {
        let path = self.pathForFile(filename)
        let parser = FastFountainParser(file: path)
        self.elements = Array(parser.elements)
    }

    func elementType(at index: Int) -> String {
        let element = self.elements[index]
        return element.elementType
    }

    func elementText(at index: Int) -> String {
        let element = self.elements[index]
        return element.elementText
    }

    func sectionDepthOfElement(at index: Int) -> Int {
        let element = self.elements[index]

        if element.elementType != "Section Heading" {
            XCTFail("Element at index \(index) is not a section header")
        }

        return element.sectionDepth
    }

    func sceneNumberForElement(at index: Int) -> String? {
        let element = self.elements[index]
        return element.sceneNumber
    }

    func errorForElement(at index: Int) -> String {
        let description = self.elements[index].description()
        return String(format: "%@¶", description)
    }
}
