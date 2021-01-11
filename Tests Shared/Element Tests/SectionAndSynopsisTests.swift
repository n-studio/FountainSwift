//
//  SectionAndSynopsisTests.m
//  Fountain
//
//  Created by Nima Yousefi on 7/11/13.
//  Copyright (c) 2013 Nima Yousefi. All rights reserved.
//

import Foundation
import XCTest
@testable import FountainSwift

class SectionAndSynopsisTests: BaseElementTests {
    override func setUp() {
        super.setUp()
        self.loadTestFile("Sections-Complex")
    }

    // MARK: - Test

    func testSectionHeader() {
        let index = 3
        XCTAssertEqual(self.elementType(at: index), "Section Heading", self.errorForElement(at :index))
        XCTAssertEqual(self.sectionDepthOfElement(at: index), 1, self.errorForElement(at :index))
    }

    func testSectionHeaderWithoutPrecedingNewline() {
        let index = 4
        XCTAssertEqual(self.elementType(at: index), "Section Heading", self.errorForElement(at :index))
        XCTAssertEqual(self.sectionDepthOfElement(at: index), 2, self.errorForElement(at :index))
    }

    func testSynopsisWithoutPrecedingNewline() {
        let index = 1
        XCTAssertEqual(self.elementType(at: index), "Synopsis", self.errorForElement(at :index))
    }
}
