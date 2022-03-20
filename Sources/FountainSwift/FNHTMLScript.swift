//
//  FNHTMLScript.m
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

open class FNHTMLScript {
    let BOLD_ITALIC_UNDERLINE_PATTERN = "(_\\*{3}|\\*{3}_)([^<>]+)(_\\*{3}|\\*{3}_)"
    let BOLD_ITALIC_PATTERN            = "(\\*{3})([^<>]+)(\\*{3})"
    let BOLD_UNDERLINE_PATTERN         = "(_\\*{2}|\\*{2}_)([^<>]+)(_\\*{2}|\\*{2}_)"
    let ITALIC_UNDERLINE_PATTERN       = "(_\\*{1}|\\*{1}_)([^<>]+)(_\\*{1}|\\*{1}_)"
    let BOLD_PATTERN                   = "(\\*{2})([^<>]+)(\\*{2})"
    let ITALIC_PATTERN                 = "(?<!\\\\)(\\*{1})([^<>]+)(\\*{1})"
    let UNDERLINE_PATTERN              = "(_)([^<>_]+)(_)"

    var script: FNScript
    var font: Font?

    public init(script: FNScript) {
        self.script = script
        self.font = Font(name: "Courier", size: 13)
    }

    public func html() -> String {
        var html: String = ""
        html.append("<!DOCTYPE html>\n")
        html.append("<html>\n")
        html.append("<head>\n")
        html.append("<style type='text/css'>\n")
        html.append(self.cssText)
        html.append("</style>\n")
        html.append("</head>\n")
        html.append("<body>\n<article>\n<section>\n")
        html.append(self.bodyText)
        html.append("</section>\n</article>\n</body>\n")
        html.append("</html>\n")
        return html
    }

    func htmlClass(forType elementType: String) -> String {
        return elementType.lowercased().replacingOccurrences(of: " ", with: "-")
    }

    lazy var cssText: String = {
        let mainBundleUrl = Bundle(for: FNHTMLScript.self).url(forResource: "ScriptCSS", withExtension: "css")
        let moduleBundleUrl = Bundle(for: FNHTMLScript.self).resourceURL?.appendingPathComponent("FountainSwift_FountainSwift.bundle").appendingPathComponent("ScriptCSS.css")

        guard let url = mainBundleUrl ?? moduleBundleUrl else {
            NSLog("Couldn't load CSS")
            return ""
        }

        let css: String
        do {
            css = try String(contentsOf: url)
        }
        catch {
            NSLog("Couldn't read CSS at %@", url.description)
            css = ""
        }
        return css
    }()

    lazy var bodyText: String = {
        var body = ""

        // Add title page
        var titlePage: [String: [String]] = [:]
        for dict in self.script.titlePage {
            dict.forEach { (key: String, values: [String]) in
                titlePage[key] = values
            }
        }

        if titlePage.count > 0 {
            body.append("<div id='script-title'>")

            // Title
            let title: String
            if let titleValues = titlePage["title"] {
                title = titleValues.joined(separator: "<br>")
            }
            else {
                title = "Untitled"
            }
            body.append("<p class='title'>\(title)</p>")

            // Credit
            let creditValues = titlePage["credit"]
            let authorValues = titlePage["authors"]

            if creditValues != nil || authorValues != nil {
                let credit: String
                if let creditValues = creditValues {
                    credit = creditValues.joined(separator: "<br>")
                }
                else {
                    credit = "written by"
                }
                body.append("<p class='credit'>\(credit)</p>")

                // Authors
                let authors: String
                if let authorValues = authorValues {
                    authors = authorValues.joined(separator: "<br>")
                }
                else {
                    authors = "Anonymous"
                }
                body.append("<p class='authors'>\(authors)</p>")
            }

            // Source
            if let sourceValues = titlePage["source"] {
                let source = sourceValues.joined(separator: "<br>")
                body.append("<p class='source'>\(source)</p>")
            }

            // Draft date
            if let draftDateValues = titlePage["draft date"] {
                let draftDate = draftDateValues.joined(separator: "<br>")
                body.append("<p class='draft date'>\(draftDate)</p>")
            }

            // Contact
            if let contactValues = titlePage["contact"] {
                let contact = contactValues.joined(separator: "<br>")
                body.append("<p class='contact'>\(contact)</p>")
            }

            body.append("</div>")
        }

        var dualDialogueCharacterCount = 0
        let dialogueTypes = ["Character", "Dialogue", "Parenthetical"]
        let ignoringTypes = ["Boneyard", "Comment", "Synopsis", "Section Heading"]

        let paginator = FNPaginator(script: self.script)
        let maxPages = paginator.numberOfPages()

        for pageIndex in 0..<maxPages {
            let elementsOnPage = paginator.page(at: pageIndex)

            // Print what page we're on -- used for page jumper
            body.append("<p class='page-break'>\(pageIndex + 1).</p>\n")

            for element in elementsOnPage {
                if ignoringTypes.contains(element.elementType) {
                    continue
                }

                if element.elementType == "Page Break" {
                    body.append("</section>\n<section>\n")
                    continue
                }

                if element.elementType == "Character" && element.isDualDialogue {
                    dualDialogueCharacterCount += 1
                    if (dualDialogueCharacterCount == 1) {
                        body.append("<div class='dual-dialogue'>\n")
                        body.append("<div class='dual-dialogue-left'>\n")
                    }
                    else if (dualDialogueCharacterCount == 2) {
                        body.append("</div>\n<div class='dual-dialogue-right'>\n")
                    }
                }

                if dualDialogueCharacterCount >= 2 && !dialogueTypes.contains(element.elementType) {
                    dualDialogueCharacterCount = 0
                    body.append("</div>\n</div>\n")
                }

                var text = ""
                if let sceneNumber = element.sceneNumber, element.elementType == "Scene Heading" {
                    text.append("<span class='scene-number-left'>\(sceneNumber)</span>")
                    text.append(element.elementText)
                    text.append("<span class='scene-number-right'>\(sceneNumber)</span>")
                }
                else {
                    text.append(element.elementText)
                }

                if element.elementType == "Character" && element.isDualDialogue {
                    // Remove any carets
                    text = text.replacingOccurrences(of: "^", with: "", options: .caseInsensitive)
                }

                if element.elementType == "Character" {
                    text = text.replace(pattern: "^@", with: "")
                }

                if element.elementType == "Scene Heading" {
                    text = text.replace(pattern: "^\\.", with: "")
                }

                if element.elementType == "Lyrics" {
                    text = text.replace(pattern: "^~", with: "")
                }

                if element.elementType == "Action" {
                    text = text.replace(pattern: "^\\!", with: "")
                }

                text = text.replace(pattern: BOLD_ITALIC_UNDERLINE_PATTERN, with: "<strong><em><u>$2</strong></em></u>")
                text = text.replace(pattern: BOLD_ITALIC_PATTERN, with: "<strong><em>$2</strong></em>")
                text = text.replace(pattern: BOLD_UNDERLINE_PATTERN, with: "<strong><u>$2</u></strong>")
                text = text.replace(pattern: ITALIC_UNDERLINE_PATTERN, with: "<em><u>$2</em></u>")
                text = text.replace(pattern: BOLD_PATTERN, with: "<strong>$2</strong>")
                text = text.replace(pattern: ITALIC_PATTERN, with: "<em>$2</em>")
                text = text.replace(pattern: UNDERLINE_PATTERN, with: "<u>$2</u>")

                text = text.replace(pattern: "\\[{2}(.*?)\\]{2}", with: "")

                if text != "" {
                    var additionalClasses = ""
                    if element.isCentered {
                        additionalClasses.append(" center")
                    }
                    body.append("<p class='\(htmlClass(forType: element.elementType))\(additionalClasses)'>\(text)</p>\n")
                }
            }
        }

        return body
    }()
}
