//
//  FNScript.m
//
//  Copyright (c) 2012-2013 Nima Yousefi & John August
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

open class FNScript {
    var filename: String?
    open var elements: [FNElement] = []
    open var titlePage: [[String: [String]]] = []
    open var suppressSceneNumbers: Bool

    public convenience init(file path: String) {
        self.init()
        self.loadFile(path)
    }

    public convenience init(string: String) {
        self.init()
        self.loadString(string)
    }

    init() {
        self.suppressSceneNumbers = false
    }

    func loadFile(_ path: String) {
        self.filename = (path as NSString).lastPathComponent
        let parser = FastFountainParser(file: path)
        self.elements = parser.elements
        self.titlePage = parser.titlePage
    }

    func loadString(_ string: String) {
        self.filename = nil
        let parser = FastFountainParser(string: string)
        self.elements = parser.elements
        self.titlePage = parser.titlePage
    }

    func stringFromDocument() -> String {
        return ""
//        return FountainWriter.documentFromScript(self)
    }

    func stringFromTitlePage() -> String {
        return ""
//        return FountainWriter.titlePageFromScript(self)
    }

    func stringFromBody() -> String {
        return ""
//        return FountainWriter.bodyFromScript(self)
    }

    func writeToFile(path: String) -> Bool {
        return false
        // Get the document
//        NSString *document = [FountainWriter documentFromScript:self)
//        NSError *error = nil;
//        BOOL success = [document writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error)
//        if (!success) {
//            // Your error handling code goes here
//        }
//        return success;
    }

    func writeToURL(url: URL) -> Bool {
        return false
        // Get the document
//        let document = FountainWriter.documentFromScript(self)
//        NSError *error = nil;
//        BOOL success = [document writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:&error)
//        if (!success) {
//            // Your error handling code goes here
//        }
//        return success;
    }

    func description() -> String {
        return ""
//        return FountainWriter.documentFromScript(self)
    }
}
