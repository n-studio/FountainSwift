//
//  Regex.swift
//  FountainSwift
//
//  Created by Matthew Nguyen on 11/01/2021.
//

import Foundation

internal extension String {
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }

    subscript(bounds: CountableRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        if end < start { return "" }
        return self[start..<end]
    }

    subscript(bounds: CountableClosedRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        if end < start { return "" }
        return self[start...end]
    }

    subscript(bounds: CountablePartialRangeFrom<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(endIndex, offsetBy: -1)
        if end < start { return "" }
        return self[start...end]
    }

    subscript(bounds: PartialRangeThrough<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        if end < startIndex { return "" }
        return self[startIndex...end]
    }

    subscript(bounds: PartialRangeUpTo<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        if end < startIndex { return "" }
        return self[startIndex..<end]
    }

    static func ~= (lhs: String, rhs: String) -> Bool {
        return lhs.matches(for: rhs, options: []).count > 0
    }

    func matches(for pattern: String, at rangeAt: Int = 0, options: NSRegularExpression.Options = .caseInsensitive) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else { return [] }
        let matches = regex.matches(in: self, range: NSRange(self.startIndex..., in: self))
        return matches.compactMap { match in
            guard let range = Range(match.range(at: rangeAt), in: self) else { return nil }
            return String(self[range])
        }
    }

    func replace(pattern: String, with template: String, options: NSRegularExpression.Options = .caseInsensitive) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else { return self }
        if self.matches(for: pattern, options: options).count > 0 {
            let range: NSRange = NSMakeRange(0, self.count)
            return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: template)
        }
        return self
    }
}
