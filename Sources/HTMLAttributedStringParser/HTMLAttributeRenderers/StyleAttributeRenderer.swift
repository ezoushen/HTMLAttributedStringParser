//
//  StyleAttributeRenderer.swift
//  
//
//  Created by EZOU on 2022/9/11.
//

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

open class StyleAttributeParser: HTMLAttributeRenderer {

    public init(fontProvider: FontProvider = FontProvider()) {
        self.fontProvider = fontProvider
    }

    public let fontProvider: FontProvider

    public var key: String { "style" }
    public var supportedTagNames: Set<String>? { nil }

    open func render(value: String) -> [NSAttributedString.Key: Any]? {
        let properties = styleParser(value)
        var attributes = [NSAttributedString.Key: Any]()

        func applyAttribute(_ key: NSAttributedString.Key, value: Any) {
            attributes[key] = value
        }

        var fontSize: CGFloat?
        var fontFamily: String?
        var fontWeight: Int?

        let paragraphStyle = NSMutableParagraphStyle()
        var paragraphStyleMutated = false

        for (key, value) in properties {
            let value = value.trimmingCharacters(in: .whitespacesAndNewlines)
            switch key {
            case "color":
                guard let color = Color(cssStyle: value) else { continue }
                applyAttribute(.foregroundColor, value: color)
            case "background-color":
                guard let color = Color(cssStyle: value) else { continue }
                applyAttribute(.backgroundColor, value: color)
            case "font-size":
                guard let size = PxConvertor.toPoint(value: value) else { continue }
                fontSize = CGFloat(size)
            case "font-family":
                fontFamily = value
            case "font-weight":
                fontWeight = Int(value)
            case "line-height":
                guard let size = PxConvertor.toPoint(value: value) else { continue }
                paragraphStyleMutated = true
                paragraphStyle.maximumLineHeight = size
                paragraphStyle.minimumLineHeight = size
            case "text-align":
                guard let alignment = parseTextAlign(value) else { continue }
                paragraphStyleMutated = true
                paragraphStyle.alignment = alignment
            case "text-decoration":
                parseTextDecoration(value, attributes: &attributes)
            default:
                continue
            }
        }
        if paragraphStyleMutated {
            applyAttribute(.paragraphStyle, value: paragraphStyle)
        }
        if fontSize != nil || fontFamily != nil || fontWeight != nil {
            let font = fontProvider.createFont(
                name: fontFamily, ofSize: fontSize, weight: fontWeight)
            applyAttribute(.font, value: font)
        }
        return attributes.isEmpty ? nil : attributes
    }

    /// Create a dictionary keyed by style properties
    private func styleParser(_ string: String) -> [String: String] {
        let startIndex = string.startIndex
        let endIndex = string.endIndex
        var start = startIndex // Cursor
        var result: [String: String] = [:]
        var key: String = ""
        for (offset, char) in string.enumerated() {
            switch char {
            case ":":
                // End of the key, start parsing the value
                key = String(string[start..<string.index(startIndex, offsetBy: offset)])
                start = string.index(startIndex, offsetBy: offset + 1, limitedBy: endIndex) ?? endIndex
            case ";":
                // End of the value, start parsing next key
                result[key] = String(string[start..<string.index(startIndex, offsetBy: offset)])
                start = string.index(startIndex, offsetBy: offset + 1, limitedBy: endIndex) ?? endIndex
                // Reset parsed key
                key = ""
            default:
                continue
            }
        }
        if !key.isEmpty {
            result[key] = String(string[start..<string.endIndex])
        }
        return result
    }

    private func parseTextAlign(_ value: String) -> NSTextAlignment? {
        switch value {
        case "left": return .left
        case "right": return .right
        case "center": return .center
        default: return nil
        }
    }

    private func parseTextDecoration(
        _ value: String,
        attributes: inout [NSAttributedString.Key: Any])
    {
        var pendingStyle: NSUnderlineStyle?
        var pendingColor: Color?

        func applyLine(
            _ style: NSAttributedString.Key,
            _ color: NSAttributedString.Key,
            attributes: inout [NSAttributedString.Key: Any])
        {
            attributes[style] = pendingStyle?.union(.single).rawValue ?? NSUnderlineStyle.single.rawValue
            guard let pendingColor = pendingColor else { return }
            attributes[color] = pendingColor
        }

        func applyStyle(_ style: NSUnderlineStyle, attributes: inout [NSAttributedString.Key: Any]) {
            let currentUnderline = attributes[.underlineStyle] as? Int
            let currentStrikethrough = attributes[.strikethroughStyle] as? Int
            if let currentUnderline {
                attributes[.underlineStyle] =
                    NSUnderlineStyle(rawValue: currentUnderline).union(style).rawValue
            }
            if let currentStrikethrough {
                attributes[.strikethroughStyle] =
                    NSUnderlineStyle(rawValue: currentStrikethrough).union(style).rawValue
            }
            if currentUnderline == nil && currentStrikethrough == nil {
                pendingStyle = style
            }
        }

        func applyColor(_ color: Color, attributes: inout [NSAttributedString.Key: Any]) {
            let containsUnderline = attributes.keys.contains(.underlineStyle)
            let containsStrikethrough = attributes.keys.contains(.strikethroughStyle)
            if containsUnderline {
                attributes[.underlineColor] = color
            }
            if containsStrikethrough {
                attributes[.strikethroughColor] = color
            }
            if !containsUnderline && !containsStrikethrough {
                pendingColor = color
            }
        }

        attributes = value.split(separator: " ").reduce(into: attributes) {
            switch $1 {
            // Line
            case "underline":    applyLine(.underlineStyle, .underlineColor, attributes: &$0)
            case "line-through": applyLine(.strikethroughStyle, .strikethroughColor, attributes: &$0)
            // Style
            case "dotted": applyStyle(.patternDot, attributes: &$0)
            case "solid":  applyStyle(.single, attributes: &$0)
            case "double": applyStyle(.double, attributes: &$0)
            case "dashed": applyStyle(.patternDash, attributes: &$0)
            default:
                // Color
                if let color = Color(cssStyle: String($1)) {
                    applyColor(color, attributes: &$0)
                }
            }
        }
    }
}
