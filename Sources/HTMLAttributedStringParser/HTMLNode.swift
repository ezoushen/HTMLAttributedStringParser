//
//  HTMLNode.swift
//  
//
//  Created by EZOU on 2022/9/11.
//

import Foundation

protocol HTMLNode: AnyObject {
    var tagName: String { get }
    var children: [any HTMLNode] { get }
    var derivedAttributes: [NSAttributedString.Key: Any]? { get set }

    func toAttributedString() throws -> NSAttributedString
}

class TaggedHTMLNode: HTMLNode {
    let tagName: String
    let attributes: [String: String]

    init(tagName: String, attributes: [String: String]) {
        self.tagName = tagName
        self.attributes = attributes
    }

    var derivedAttributes: [NSAttributedString.Key : Any]? = nil
    var children: [any HTMLNode] = []
    var tagRendererProvider: (any TagRendererProvider)?
    var attributeRendererProvider: (any AttributeRendererProvider)?

    func toAttributedString() throws -> NSAttributedString {
        let attributedString = NSMutableAttributedString()
        let derivedAttributes = try attributes.reduce(into: derivedAttributes ?? [:]) {
            guard let renderer = attributeRendererProvider?
                    .attributeRenderer(forKey: $1.key, tag: tagName),
                  let attributes = try renderer.render(value: $1.value) else { return }
            $0.merge(attributes) { $1 }
        }
        for child in children {
            child.derivedAttributes = derivedAttributes
            attributedString.append(try child.toAttributedString())
        }
        if let tagRenderer = tagRendererProvider?.tagRenderer(forTag: tagName) {
            try tagRenderer.render(
                string: attributedString,
                attributes: attributes,
                derivedAttributes: derivedAttributes.isEmpty ? nil : derivedAttributes)
        }
        return attributedString
    }
}

class PlainTextHTMLNode: HTMLNode {
    var tagName: String { "" }
    var children: [HTMLNode] { [] }

    init(content: String) {
        self.content = content
    }

    let content: String
    var derivedAttributes: [NSAttributedString.Key : Any]?

    func toAttributedString() throws -> NSAttributedString {
        let string = NSMutableAttributedString(string: content)
        if let parentAttributes = derivedAttributes {
            string.addAttributes(
                parentAttributes,
                range: NSRange(location: 0, length: string.length))
        }
        return string
    }
}
