//
//  FNPaginator.m
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
import CoreGraphics
#if os(macOS)
import AppKit
#else
import UIKit
#endif

class FNPaginator {
    var script: FNScript
    var pages: [[FNElement]]

    init(script: FNScript) {
        self.pages = []
        self.script = script
    }

    // Default pagination function for US Letter paper size
    func paginate()
    {
        // US letter paper size is 8.5 x 11 (in pixels)
        let letterPaperSize = CGSize(width: 612, height: 792)

        // run pagination
        self.paginate(for: letterPaperSize)
    }

    func page(at index: Int) -> [FNElement] {
        // Make sure some kind of pagination has been run before you try to return a value.
        if self.pages.count == 0 {
            paginate()
        }

        // Make sure we don't try and access an index that doesn't exist
        if self.pages.count == 0 || index > (self.pages.count - 1) {
            return []
        }

        return self.pages[index]
    }

    func numberOfPages() -> Int
    {
        // Make sure some kind of pagination has been run before you try to return a value.
        if self.pages.count == 0 {
            self.paginate()
        }
        return self.pages.count
    }

    func paginate(for pageSize: CGSize) {
        autoreleasepool {
            let oneInchBuffer: CGFloat = 72
            let maxPageHeight: CGFloat = pageSize.height - (oneInchBuffer * 2.01).rounded()

            let font: Font = Font(name: "Courier", size: 12)!
            let lineHeight = font.pointSize

            var spaceBefore: CGFloat
            var elementWidth: CGFloat
            var blockHeight: CGFloat = 0

            let initialY: CGFloat = 0 // initial starting point on page
            var currentY = initialY
            var currentPage: [FNElement] = []

            // create a tmp array that will hold elements to be added to the pages
            var tmpElements: [FNElement] = []
            let maxElements = self.script.elements.count

            var previousDualDialogueBlockHeight: CGFloat = -1

            var i = -1
            // walk through the elements array
            while i < maxElements - 1 {
                i += 1

                let element  = self.script.elements[i]

                // catch page breaks immediately
                if element.elementType == "Page Break" {

                    if tmpElements.count > 0 {
                        for e in tmpElements {
                            currentPage.append(e)
                        }

                        // reset the tmp elements holder
                        tmpElements = []
                    }

                    // close the open page
                    currentPage.append(element)
                    self.pages.append(currentPage)

                    // reset currentPage and the currentY value
                    currentPage = []
                    currentY = initialY

                    continue
                }

                // get spaceBefore, the leftMargin, and the elementWidth
                spaceBefore = self.spaceBefore(for: element) * lineHeight.rounded()
                elementWidth = self.width(for: element)

                // get the height of the text
                let height = self.height(for: element.elementText, font: font, maxWidth: elementWidth, lineHeight: lineHeight)

                // data integrity check
                if height <= 0 {
                    // height = lineHeight
                    continue
                }

                blockHeight += height

                // only add the space before if we're not at the top of the current page
                if currentPage.count > 0 {
                    blockHeight += spaceBefore
                }

                // if it's a screne heading, get the next block
                // if it's a character cue, we need to get the entire dialogue block
                if element.elementType == "Scene Heading" && (i + 1) < maxElements {
                    let nextElement = self.script.elements[i + 1]
                    let nextElementWidth = self.width(for: nextElement)
                    let nextElementHeight = self.height(for: nextElement.elementText, font: font, maxWidth: nextElementWidth, lineHeight: lineHeight)

                    if (blockHeight + currentY + nextElementHeight >= maxPageHeight && nextElementHeight >= lineHeight * 1) {
                        let forcedBreak = FNElement(type: "Page Break", text: "")
                        tmpElements.append(forcedBreak)
                    }

                    tmpElements.append(element)
                    continue
                }
                else if (element.elementType == "Character" && (i + 1) < maxElements) {
                    let dialogueBlockTypes = ["Dialogue", "Parenthetical"]

                    var j = i + 1
                    var nextElement = element
                    var isEndOfArray = false
                    repeat {
                        tmpElements.append(nextElement)

                        if (j < maxElements) {
                            nextElement = self.script.elements[j]
                            j += 1
                            if dialogueBlockTypes.contains(nextElement.elementType) {
                                blockHeight += self.height(for: nextElement.elementText, font: font, maxWidth: elementWidth, lineHeight: lineHeight)
                            }
                        }
                        else {
                            isEndOfArray = true
                        }
                    } while (!isEndOfArray && dialogueBlockTypes.contains(nextElement.elementType))

                    // reset i to j - 2 because we need to hit the last element again (j - 1) and the loop will
                    // auto iterate +1 the next time through (so -2 total)
                    if (isEndOfArray) {
                        // if the script ends in a dialogue block, we need this to make sure we don't duplicate the last line.
                        i = j - 1
                    }
                    else {
                        i = j - 2
                    }

                    if (element.isDualDialogue && previousDualDialogueBlockHeight < 0) {
                        previousDualDialogueBlockHeight = blockHeight
                    }
                    else if (element.isDualDialogue) {
                        let heightDiff = abs(previousDualDialogueBlockHeight - blockHeight)
                        blockHeight = heightDiff
                        previousDualDialogueBlockHeight = -1
                    }
                }
                else {
                    tmpElements.append(element)
                }

                let totalHeightUsed = blockHeight + currentY

                // At the end of the page
                if totalHeightUsed > maxPageHeight {
                    // This is how we handle breaking a Character's dialogue across pages
                    if tmpElements.count > 0 && tmpElements[0].elementType == "Character" && (totalHeightUsed - maxPageHeight >= lineHeight * 4) {
                        var blockIndex = -1 // initial to -1 because we interate immediately
                        let maxTmpElements = tmpElements.count

                        // if there are two lines free below the character cue, we can try to squeeze this block in.
                        var partialHeight: CGFloat = 0
                        let pageOverflow = totalHeightUsed - maxPageHeight

                        // figure out what index spills over the page
                        while (partialHeight < pageOverflow && blockIndex < maxTmpElements - 1) {
                            blockIndex += 1
                            let element = tmpElements[blockIndex]
                            let height = self.height(for: element.elementText, font: font, maxWidth: self.width(for: element), lineHeight: lineHeight)
                            let space = self.spaceBefore(for: element) * lineHeight.rounded()
                            partialHeight += (height + space)
                        }

                        if blockIndex > 0 {
                            // determine what type of element spills
                            let spiller = tmpElements[blockIndex]
                            if spiller.elementType == "Parenthetical" {
                                // break before, unless we're index 1 (the second element)
                                if blockIndex > 1 {
                                    for z in 0..<blockIndex {
                                        currentPage.append(tmpElements[z])
                                    }

                                    // add the more at the bottom of the page
                                    let more = FNElement(type: "Character", text: "(MORE)")

                                    currentPage.append(more)

                                    // close the page
                                    self.pages.append(currentPage)
                                    currentPage = []

                                    // reset the block height
                                    blockHeight = 0

                                    // add the remaining elements, plus the character cue, to the previous page
                                    let characterCue = tmpElements[0]
                                    characterCue.elementText = "\(characterCue.elementText) (CONT'D)"

                                    blockHeight += self.height(for: characterCue.elementText, font: font, maxWidth: self.width(for: characterCue), lineHeight: lineHeight)

                                    currentPage.append(characterCue)

                                    for z in blockIndex..<maxTmpElements {
                                        let e = tmpElements[z]
                                        currentPage.append(tmpElements[z])
                                        blockHeight += self.height(for: e.elementText, font: font, maxWidth: self.width(for: e), lineHeight: lineHeight)
                                    }

                                    // set the currentY
                                    currentY = blockHeight

                                    // reset the tmpElements
                                    tmpElements = []
                                }

                            }
                            else {
                                let distanceToBottom = maxPageHeight - currentY - (lineHeight * 2)
                                if distanceToBottom < lineHeight * 5 {
                                    self.pages.append(currentPage)
                                    currentPage = []
                                    currentY = blockHeight - spaceBefore
                                    blockHeight = 0
                                    continue
                                }

                                var heightBeforeDialogue: CGFloat = 0
                                for z in 0..<blockIndex {
                                    let e = tmpElements[z]
                                    heightBeforeDialogue += self.spaceBefore(for: e)
                                    heightBeforeDialogue += self.height(for: e.elementText, font: font, maxWidth: self.width(for: e), lineHeight: lineHeight)
                                }

                                var dialogueHeight = heightBeforeDialogue
                                var sentenceIndex = -1
                                let sentences = spiller.elementText.matches(for: "(.+?[\\.\\?\\!]+\\s*)", at: 1)
                                let maxSentences = sentences.count

                                var dialogueBeforeBreak = ""

                                while ((dialogueHeight < distanceToBottom) && (sentenceIndex < maxSentences - 1)) {
                                    sentenceIndex += 1
                                    let text = "\(dialogueBeforeBreak)\(sentences[sentenceIndex])"
                                    let h = self.height(for: text, font: font, maxWidth: self.width(for: tmpElements[blockIndex]), lineHeight: lineHeight)
                                    dialogueHeight = h

                                    if (dialogueHeight < distanceToBottom) {
                                        dialogueBeforeBreak.append(sentences[sentenceIndex])
                                    }
                                }

                                // now break up the sentences into two dialogue elements
                                let preBreakDialogue = FNElement(type: "Dialogue", text: dialogueBeforeBreak)

                                if preBreakDialogue.elementText != "" {
                                    // we need to split this element's text so that it fits on both pages
                                        for z in 0..<blockIndex {
                                        currentPage.append(tmpElements[z])
                                    }

                                    currentPage.append(preBreakDialogue)

                                    // add the more at the bottom of the page
                                    let more = FNElement(type: "Character", text: "(MORE)")

                                    currentPage.append(more)

                                    // close the page
                                    self.pages.append(currentPage)
                                    currentPage = []
                                }
                                else {
                                    self.pages.append(currentPage)
                                    currentPage = []

                                    for z in 1..<blockIndex {
                                        currentPage.append(tmpElements[z])
                                    }
                                }

                                // reset the block height
                                blockHeight = 0

                                // add the remaining elements, plus the character cue, to the previous page
                                let characterCue = FNElement(type: "Character", text: tmpElements[0].elementText)

                                blockHeight += self.height(for: characterCue.elementText, font: font, maxWidth: self.width(for: characterCue), lineHeight: lineHeight)

                                currentPage.append(characterCue)

                                // create the postBreakDialogue
                                if sentenceIndex < 0 {
                                    sentenceIndex = 0
                                }

                                var dialogueAfterBreak = ""
                                for z in sentenceIndex..<maxSentences {
                                    dialogueAfterBreak.append(sentences[z])
                                }

                                let postBreakDialogue = FNElement(type: "Dialogue", text: dialogueAfterBreak)

                                blockHeight += self.height(for: postBreakDialogue.elementText, font:font, maxWidth: self.width(for: postBreakDialogue), lineHeight: lineHeight)

                                currentPage.append(postBreakDialogue)

                                // add remaining elements
                                if (blockIndex + 1 < maxTmpElements) {
                                    for z in (blockIndex + 1)..<maxTmpElements {
                                        let element = tmpElements[z]
                                        currentPage.append(tmpElements[z])
                                        blockHeight += self.height(for: element.elementText, font: font, maxWidth: self.width(for: element), lineHeight: lineHeight)
                                    }
                                }

                                // set the currentY
                                currentY    = blockHeight;

                                // reset the tmpElements
                                tmpElements = []
                            }
                        }
                        else {
                            self.pages.append(currentPage)
                            currentPage = []
                            currentY = blockHeight - spaceBefore
                        }
                    }
                    else {
                        self.pages.append(currentPage)
                        currentPage = []
                        currentY = blockHeight - spaceBefore
                        blockHeight = 0
                    }

                }
                else {
                    currentY = blockHeight + currentY
                }

                blockHeight = 0

                // add all the tmp elements to the current page
                for element in tmpElements {
                    currentPage.append(element)
                }

                // reset the tmp elements holder
                tmpElements = []

            }

            if tmpElements.count > 0 {
                for element in tmpElements {
                    currentPage.append(element)
                }
            }

            // add the last page of the script to the array
            if currentPage.count > 0 {
                self.pages.append(currentPage)
            }
        }
    }

    // MARK: - Helper class methods

    func spaceBefore(for element: FNElement) -> CGFloat {
        var spaceBefore: CGFloat = 0

        let type  = element.elementType

        if type == "Scene Heading" {
            spaceBefore = 2
        }
        else if ["Action", "General", "Character", "Transition"].contains(type) {
            spaceBefore = 1
        }

        return spaceBefore
    }

    func leftMargin(for element: FNElement) -> CGFloat {
        var leftMargin: CGFloat = 0
        let type = element.elementType

        if ["Scene Heading", "Action", "General"].contains(type) {
            leftMargin  = 106
        }
        else if type == "Character" {
            leftMargin  = 247
        }
        else if type == "Dialogue" {
            leftMargin  = 177
        }
        else if type == "Parenthetical" {
            leftMargin  = 205
        }
        else if type == "Transition" {
            leftMargin  = 106
        }

        return leftMargin
    }

    func width(for element: FNElement) -> CGFloat {
        var width: CGFloat = 0
        let type = element.elementType

        if ["Action", "General", "Scene Heading", "Transition"].contains(type) {
            width = 430
        }
        else if type == "Character" {
            width = 250
        }
        else if type == "Dialogue" {
            width = 250
        }
        else if type == "Parenthetical" {
            width = 212
        }

        return width
    }

    /*
     To get the height of a string we need to create a text layout box, and use that to calculate the number
     of lines of text we have, then multiply that by the line height. This is NOT the method Apple describes
     in their docs, but we have to do this because getting the size of the layout box (Apple's recommended
     method) doesn't take into account line height, so text won't display correctly when we try and print.
     */
    func height(for string: String, font: Font, maxWidth: CGFloat, lineHeight: CGFloat) -> CGFloat {
        /*
         This method won't work on iOS. For iOS you'll need to adjust the font size to 80% and use the NSString instance
         method - (CGSize)sizeWithFont:constrainedToSize:lineBreakMode:
         */

        // set up the layout manager
        let textStorage = NSTextStorage(string: string, attributes: [NSAttributedString.Key.font: font])

        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize(width: maxWidth, height: .greatestFiniteMagnitude))

        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        textContainer.lineFragmentPadding = 0.0

        layoutManager.glyphRange(for: textContainer)

        // get the number of lines
        var numberOfLines: Int = 0
        var index: Int = 0
        let numberOfGlyphs = layoutManager.numberOfGlyphs

        var lineRange = NSRange(location: 0, length: string.count)

        while index < numberOfGlyphs {
            layoutManager.lineFragmentRect(forGlyphAt: index, effectiveRange: &lineRange)
            index = NSMaxRange(lineRange);
            numberOfLines += 1
        }

        // calculate the height
        let height = CGFloat(numberOfLines) * lineHeight
        return height
    }
}
