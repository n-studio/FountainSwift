//
//  FastFountainParser.m
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

internal enum FastFountainParserPattern: String {
    case inlinePattern = "^([^\\t\\s][^:]+):\\s*([^\\t\\s].*$)"
    case directivePattern = "^([^\\t\\s][^:]+):([\\t\\s]*$)"
    case contentPattern = ""
}

class FastFountainParser {
    var elements: [FNElement] = []
    var titlePage: [[String: [String]]] = []

    init(string: String) {
        self.parseContents(string)
    }

    init(file path: String) {
        do {
            let contents = try String(contentsOf: URL(fileURLWithPath: path), encoding: .utf8)
            self.parseContents(contents)
        }
        catch {
            NSLog("Couldn't read the file %@", path)
        }
    }

    func parseContents(_ contents: String) {
        var contents: String = contents
        // Trim leading newlines from the document
        contents = contents.replace(pattern: "^\\s*", with: "")
        contents = contents.replacingOccurrences(of: "\r\n", with: "\n")
        contents = String(format: "%@\n\n", contents)

        // Find the first newline
        let topOfDocument: String
        if let firstBlankLineRange = contents.range(of: "\n\n") {
            topOfDocument = String(contents[..<firstBlankLineRange.lowerBound])
        }
        else {
            topOfDocument = ""
        }

        // ----------------------------------------------------------------------
        // TITLE PAGE
        // ----------------------------------------------------------------------
        // Is the stuff at the top of the document the title page?
        var foundTitlePage = false
        var openKey: String = ""
        var openValues: [String] = []
        let topLines = topOfDocument.components(separatedBy: "\n")

        for line in topLines {
            if line == "" || line ~= FastFountainParserPattern.directivePattern.rawValue {
                foundTitlePage = true
                // If a key was open we want to close it
                if openKey != "" {
                    let dict = [openKey: openValues]
                    self.titlePage.append(dict)
                }

                openKey = line.matches(for: FastFountainParserPattern.directivePattern.rawValue, at: 1).first?.lowercased() ?? ""
                if openKey == "author" {
                    openKey = "authors"
                }
            }
            else if line ~= FastFountainParserPattern.inlinePattern.rawValue {
                foundTitlePage = true
                // If a key was open we want to close it
                if openKey != "" {
                    let dict = [openKey: openValues]
                    self.titlePage.append(dict)
                    openKey = ""
                    openValues = []
                }

                var key = line.matches(for: FastFountainParserPattern.inlinePattern.rawValue, at: 1).first?.lowercased()
                let value = line.matches(for: FastFountainParserPattern.inlinePattern.rawValue, at: 2).first ?? ""

                if key == "author" {
                    key = "authors"
                }

                if let key = key {
                    let dict = [key: [value]]
                    self.titlePage.append(dict)
                    openKey = ""
                    openValues = []
                }
            }
            else if (foundTitlePage) {
                openValues.append(line.trimmingCharacters(in: .whitespaces))
            }
        }

        if (foundTitlePage) {
            if openKey != "" && openValues.count == 0 && self.titlePage.count == 0 {
                // do nothing
            }
            else {
                // Close any remaining directives
                if openKey != "" {
                    let dict = [openKey: openValues]
                    self.titlePage.append(dict)
                    openKey = ""
                    openValues = []
                }
                contents = contents.replacingOccurrences(of: topOfDocument, with: "")
            }
        }

        // ----------------------------------------------------------------------
        // BODY
        // ----------------------------------------------------------------------
        // Contents by line
        contents = String(format: "\n%@", contents)
        let lines = contents.components(separatedBy: .newlines)

        var newlinesBefore = 0
        var index = -1
        var isCommentBlock = false
        var isInsideDialogueBlock = false
        var commentText = ""
        for line in lines {
            index += 1

            // If the line starts with a tilde and the previous element was a
            // lyric element, then we keep making lyrics.
            if line.count > 0 && line[0] == "~" {
                guard let lastElement = self.elements.last else {
                    let element = FNElement(type: "Lyrics", text: line)
                    self.elements.append(element)
                    newlinesBefore = 0
                    continue
                }

                if lastElement.elementType == "Lyrics" && newlinesBefore > 0 {
                    let element = FNElement(type: "Lyrics", text: " ")
                    self.elements.append(element)
                }

                let element = FNElement(type: "Lyrics", text: line)
                self.elements.append(element)
                newlinesBefore = 0
                continue
            }

            if line.count > 0 && line[0] == "!" {
                let element = FNElement(type: "Action", text: line)
                self.elements.append(element)
                newlinesBefore = 0
                continue
            }

            if line.count > 0 && line[0] == "@" {
                let element = FNElement(type: "Character", text: line)
                self.elements.append(element)
                newlinesBefore = 0
                isInsideDialogueBlock = true
                continue
            }


            // Need to check for "empty" lines within dialogue -- denoted by two spaces inside a dialogue block
            if line ~= "^\\s{2}$" && isInsideDialogueBlock {
                newlinesBefore = 0
                // Check to see if the previous element was a dialogue
                let lastIndex = self.elements.count - 1
                let previousElement = self.elements[lastIndex]

                if previousElement.elementType == "Dialogue" {
                    let text = String(format: "%@\n%@", previousElement.elementText ?? "", line)
                    previousElement.elementText = text;
                    self.elements.remove(at: lastIndex)
                    self.elements.append(previousElement)
                }
                else {
                    let element = FNElement(type: "Dialogue", text: line)
                    self.elements.append(element)
                }
                continue
            }

            if line ~= "^\\s{2,}$" {
                let element = FNElement(type: "Action", text: line)
                self.elements.append(element)
                newlinesBefore = 0
                continue
            }

            // Blank line.
            if line == "" && !isCommentBlock {
                isInsideDialogueBlock = false
                newlinesBefore += 1
                continue
            }

            // Open Boneyard
            if line ~= "^\\/\\*" {
                if line ~= "\\*\\/\\s*$" {
                    let text = line.replacingOccurrences(of: "/*", with: "").replacingOccurrences(of: "*/", with: "")
                    isCommentBlock = false
                    let element = FNElement(type: "Boneyard", text: text)
                    self.elements.append(element)
                    newlinesBefore = 0
                }
                else {
                    isCommentBlock = true
                    commentText.append("\n")
                }
                continue
            }

            // Close Boneyard
            if line ~= "\\*\\/\\s*$" {
                let text = line.replacingOccurrences(of: "*/", with: "")
                if text == "" || text ~= "^\\s*$" {
                    commentText.append(text.trimmingCharacters(in: .whitespaces))
                }
                isCommentBlock = false
                let element = FNElement(type: "Boneyard", text: commentText)
                self.elements.append(element)
                commentText = ""
                newlinesBefore = 0
                continue
            }

            // Inside the Boneyard
            if (isCommentBlock) {
                commentText.append(line)
                commentText.append("\n")
                continue
            }

            // Page Breaks -- three or more '=' signs
            if line ~= "^={3,}\\s*$" {
                let element = FNElement(type: "Page Break", text: line)
                self.elements.append(element)
                newlinesBefore = 0
                continue
            }

            // Synopsis -- a single '=' at the start of the line
            if line.trimmingCharacters(in: .whitespaces).count > 0 && line.trimmingCharacters(in: .whitespaces)[0] == "=" {
                let text = line.replace(pattern: "^\\s*={1}", with: "")
                let element = FNElement(type: "Synopsis", text: text)
                self.elements.append(element)
                continue
            }

            // Comment -- double brackets [[Comment]]
            if line ~= "^\\s*\\[{2}\\s*([^\\]\\n])+\\s*\\]{2}\\s*$" {
                let text = line.replacingOccurrences(of: "[[", with: "").replacingOccurrences(of: "]]", with: "").trimmingCharacters(in: .whitespaces)
                let element = FNElement(type: "Comment", text: text)
                self.elements.append(element)
                continue
            }

            // Section heading -- one or more '#' at the start of the line, the number of chars == the section depth
            if line.trimmingCharacters(in: .whitespaces).count > 0 && line.trimmingCharacters(in: .whitespaces)[0] == "#" {
                newlinesBefore = 0

                // Get the depth of the section
                let depth = line.matches(for: "^\\s*#+").first?.count ?? 0

                // Cleanse the line
                let text = line[depth...].trimmingCharacters(in: .whitespaces)
                if text == "" {
                    NSLog("Error in the Section Heading")
                    continue
                }

                let element = FNElement(type: "Section Heading", text: text)
                element.sectionDepth = depth
                self.elements.append(element)
                continue
            }

            // Forced scene heading -- look for a single '.' at the start of a line
            if line.count > 1 && line[0] == "." && line[1] != "." {
                newlinesBefore = 0
                var sceneNumber: String? = nil
                var text: String? = nil
                // Check for scene numbers
                if line ~= "#([^\\n#]*?)#\\s*$" {
                    sceneNumber = line.matches(for: "#([^\\n#]*?)#\\s*$", at: 1).first
                    text = line.replace(pattern: "#([^\\n#]*?)#\\s*$", with: "")
                    text = text?[1...].trimmingCharacters(in: .whitespaces)
                }
                else {
                    text = line[1...].trimmingCharacters(in: .whitespaces)
                }

                let element = FNElement(type: "Scene Heading", text: text ?? "")
                if let sceneNumber = sceneNumber {
                    element.sceneNumber = sceneNumber;
                }
                self.elements.append(element)
                continue
            }

            // Scene Headings
            if newlinesBefore > 0 && line.matches(for: "^(INT|EXT|EST|(I|INT)\\.?\\/(E|EXT)\\.?)[\\.\\-\\s][^\\n]+$", options: .caseInsensitive).count > 0 {
                newlinesBefore = 0
                var sceneNumber: String? = nil
                var text: String? = nil
                // Check for scene numbers
                if line ~= "#([^\\n#]*?)#\\s*$" {
                    sceneNumber = line.matches(for: "#([^\\n#]*?)#\\s*$", at: 1).first
                    text = line.replace(pattern: "#([^\\n#]*?)#\\s*$", with: "")
                }
                else {
                    text = line
                }

                let element = FNElement(type: "Scene Heading", text: text ?? "")
                if let sceneNumber = sceneNumber {
                    element.sceneNumber = sceneNumber
                }
                self.elements.append(element)
                continue
            }

            // Transitions
            // We need to trim leading whitespace from the line because whitespace at the end of the line
            // nullifies Transitions.
            if line ~= "[^a-z]*TO:$" {
                newlinesBefore = 0
                let element = FNElement(type: "Transition", text: line)
                self.elements.append(element)
                continue
            }

            let lineWithTrimmedLeading = line.replace(pattern: "^\\s*", with: "")
            let transitions = ["FADE OUT.", "CUT TO BLACK.", "FADE TO BLACK."]
            if transitions.contains(lineWithTrimmedLeading) {
                newlinesBefore = 0
                let element = FNElement(type: "Transition", text: line)
                self.elements.append(element)
                continue
            }

            // Forced transitions
            if line[0] == ">" {
                if line.count > 1 && line[line.count - 1] == "<" {
                    // Remove the extra characters
                    var text = line[1...].trimmingCharacters(in: .whitespaces)
                    text = text[0..<(text.count - 1)].trimmingCharacters(in: .whitespaces)

                    let element = FNElement(type: "Action", text: text)
                    element.isCentered = true
                    self.elements.append(element)
                    newlinesBefore = 0
                    continue
                }
                else {
                    let text = line[1...].trimmingCharacters(in: .whitespaces)
                    let element = FNElement(type: "Transition", text: text)
                    self.elements.append(element)
                    newlinesBefore = 0
                    continue
                }
            }

            // Character
            if newlinesBefore > 0 && line ~= "^[^a-z]+(\\(cont'd\\))?$" {
                // look ahead to see if the next line is blank
                let nextIndex = index + 1
                if nextIndex < lines.count {
                    let nextLine = lines[index+1]
                    if nextLine != "" {
                        newlinesBefore = 0
                        let element = FNElement(type: "Character", text: line)

                        if line ~= "\\^\\s*$" {
                            element.isDualDialogue = true
                            element.elementText = element.elementText?.replace(pattern: "\\s*\\^\\s*$", with: "")
                            var foundPreviousCharacter = false
                            var index = self.elements.count - 1
                            while ((index >= 0) && !foundPreviousCharacter) {
                                let previousElement = self.elements[index]
                                if previousElement.elementType == "Character" {
                                    previousElement.isDualDialogue = true
                                    foundPreviousCharacter = true
                                }
                                index -= 1
                            }
                        }

                        self.elements.append(element)
                        isInsideDialogueBlock = true
                        continue
                    }
                }
            }

            // Dialogue and Parentheticals
            if (isInsideDialogueBlock) {
                // Find out which type of element we have
                if newlinesBefore == 0 && line ~= "^\\s*\\(" {
                    let element = FNElement(type: "Parenthetical", text: line)
                    self.elements.append(element)
                    continue
                }
                else {
                    // Check to see if the previous element was a dialogue
                    let lastIndex = self.elements.count - 1
                    let previousElement = self.elements[lastIndex]
                    if previousElement.elementType == "Dialogue" {
                        let text = String(format: "%@\n%@", previousElement.elementText ?? "", line)
                        previousElement.elementText = text;
                        self.elements.remove(at: lastIndex)
                        self.elements.append(previousElement)
                    }
                    else {
                        let element = FNElement(type: "Dialogue", text: line)
                        self.elements.append(element)
                    }
                    continue
                }
            }

            // This is for when inter element lines aren't separated by blank lines.
            if newlinesBefore == 0 && self.elements.count > 0 {
                // Get the previous action line and merge this one into it
                let lastIndex = self.elements.count - 1
                let previousElement = self.elements[lastIndex]
                // Scene Heading must be surrounded by blank lines
                if previousElement.elementType == "Scene Heading" {
                    previousElement.elementType = "Action"
                }

                let text = String(format: "%@\n%@", previousElement.elementText ?? "", line)
                previousElement.elementText = text
                self.elements.remove(at: lastIndex)
                self.elements.append(previousElement)
                newlinesBefore = 0
                continue
            }
            else {
                let element = FNElement(type: "Action", text: line)
                self.elements.append(element)
                newlinesBefore = 0
                continue
            }
        }
    }
}
