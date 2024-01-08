//
//  String+Extensions.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 30/11/2023.
//

import Foundation
import UIKit

extension String {
    func highlightedPlaceholder() -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self)

        let range = NSRange(location: 0, length: count)
        let regex = try! NSRegularExpression(pattern: "\\*", options: [])
        let matches = regex.matches(in: self, options: [], range: range)

        for match in matches {
            let nsRange = match.range
            let swiftRange = Range(nsRange, in: self)!

            let redColorAttribute: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.systemRed,
            ]

            attributedString.addAttributes(redColorAttribute, range: NSRange(swiftRange, in: self))
        }

        return attributedString
    }

    func underlinedWithCenteredLine() -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self)

        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attributedString.length))

        let fontSize = UIFont.systemFontSize
        let underlineThickness: CGFloat = 1.0

        let descender = (fontSize - underlineThickness) / 2.0
        let baselineOffset = round(descender)

        attributedString.addAttribute(NSAttributedString.Key.baselineOffset, value: baselineOffset, range: NSRange(location: 0, length: attributedString.length))

        return attributedString
    }

    func strikethrough(useStrikethrough: Bool = true) -> NSAttributedString {
        var attributes: [NSAttributedString.Key: Any] = [:]

        if useStrikethrough {
            attributes[NSAttributedString.Key.strikethroughStyle] = NSUnderlineStyle.single.rawValue
        }

        return NSAttributedString(string: self, attributes: attributes)
    }

    func decodeHTML() -> String? {
        guard let data = data(using: .utf8) else { return nil }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue,
        ]

        do {
            let attributedString = try NSAttributedString(data: data, options: options, documentAttributes: nil)
            return attributedString.string
        } catch {
            print("HTML decoding error:", error)
            return nil
        }
    }
}
