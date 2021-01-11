//
//  ForcedElementTests.m
//  Fountain
//
//  Created by Nima Yousefi on 3/14/14.
//  Copyright (c) 2014 Nima Yousefi. All rights reserved.
//

import Foundation
import XCTest
@testable import FountainSwift

class ForcedElementTests: BaseElementTests {
    override func setUp() {
        super.setUp()
        self.loadTestFile("ForcedElements")
    }

    func testForcedAction() {
        let index = 0
        XCTAssertEqual(self.elementType(at: index), "Action", self.errorForElement(at: index))
    }

    func testForcedCharacterCue() {
        let index = 1
        XCTAssertEqual(self.elementType(at: index), "Character", self.errorForElement(at: index))
    }

    func testLyrics() {
        let index = 4
        XCTAssertEqual(self.elementType(at: index), "Lyrics", self.errorForElement(at: index))
    }
}
