//
//  DialogueTests.m
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

class DialogueTests: BaseElementTests {
    override func setUp() {
        super.setUp()
        self.loadTestFile("Dialogue")
    }

    // MARK: - Tests
    // MARK: Character Cues

    func testCharacterCue() {
        let index = 0
        XCTAssertEqual(self.elementType(at: index), "Character", self.errorForElement(at: index))
    }

    func testCueWithParenthetical() {
        let index = 2
        XCTAssertEqual(self.elementType(at: index), "Character", self.errorForElement(at: index))
    }

    func testCueWithLowercaseContd() {
        let index = 9
        XCTAssertEqual(self.elementType(at: index), "Character", self.errorForElement(at: index))
    }

    func testCharacterCueWithNumbers() {
        let index = 20
        XCTAssertEqual(self.elementType(at: index), "Character", self.errorForElement(at: index))
    }

    func testCueCannotBeALLNumerical() {
        let index = 23
        XCTAssertEqual(self.elementType(at: index), "Character", self.errorForElement(at: index))
    }

    func testCueCanBeIndented() {
        let index = 27
        XCTAssertEqual(self.elementType(at: index), "Character", self.errorForElement(at: index))
    }

    // MARK: Dual dialogue

    func testCueWithCaret() {
        let index = 18
        XCTAssertEqual(self.elementType(at: index), "Character", self.errorForElement(at: index))
    }

    func testMatchingDualDialogue() {
        let index = 16
        XCTAssertEqual(self.elementType(at: index), "Character", self.errorForElement(at: index))
    }

    func testRemovalOfCaretMarkup() {
        let index = 18
        XCTAssertEqual(self.elementText(at: index), "EVE", self.errorForElement(at: index))
    }

    // MARK: Parentheticals

    func testParenthetical() {
        let index = 5
        XCTAssertEqual(self.elementType(at: index), "Parenthetical", self.errorForElement(at: index))
    }

    func testParentheticalAtEndOfBlock() {
        let index = 15
        XCTAssertEqual(self.elementType(at: index), "Parenthetical", self.errorForElement(at: index))
    }

    func testParentheticalCanBeIndent() {
        let index = 28
        XCTAssertEqual(self.elementType(at: index), "Parenthetical", self.errorForElement(at: index))
    }

    // MARK: Dialogue

    func testDialogue() {
        let index = 1
        XCTAssertEqual(self.elementType(at: index), "Dialogue", self.errorForElement(at: index))
    }

    func testDialogueWithLineBreaks() {
        let index = 12
        XCTAssertEqual(self.elementType(at: index), "Dialogue", self.errorForElement(at: index))
    }

    func testDialogueAllCaps() {
        let index = 8
        XCTAssertEqual(self.elementType(at: index), "Dialogue", self.errorForElement(at: index))
    }

    func testDialogueWithEmptyLineInTheMiddle() {
        let index = 26
        XCTAssertEqual(self.elementType(at: index), "Dialogue", self.errorForElement(at: index))
    }

    func testDialogueCanBeIndented() {
        let index = 29
        XCTAssertEqual(self.elementType(at: index), "Dialogue", self.errorForElement(at: index))
    }
}
