//
//  HTMLAttributedStringParser.swift
//
//
//  Created by EZOU on 2022/9/11.
//

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

public enum HTMLAttributedStringParserError: Error {
    case underlying(error: Error)
    case parentNodeNotFound
    case documentUnclosed
    case processedNodeNotFound
    case requiredAttributeNotFound(name: String)
}

public class HTMLAttributedStringParser {

    public private(set) var tagRenderersIndexedByName: [String: any HTMLTagRenderer] = [:]
    public private(set) var attributeRenderersIndexedByKey: [String: any HTMLAttributeRenderer] = [:]

    public init() {
        add(tagRenderer: AHTMLTagRenderer())
        add(tagRenderer: ImgHTMLTagRenderer())
        add(attributeRenderer: StyleAttributeParser())
    }

    public func add(tagRenderer: any HTMLTagRenderer) {
        tagRenderersIndexedByName[tagRenderer.tagName] = tagRenderer
    }

    public func add(attributeRenderer: any HTMLAttributeRenderer) {
        attributeRenderersIndexedByKey[attributeRenderer.key] = attributeRenderer
    }

    public func parse(htmlString: String) throws -> NSAttributedString {
        let handler = XMLParsingHandler(
            tagRendererProvider: self,
            attributeRendererProvider: self)
        let parser = XMLParser(data: htmlString.data(using: .utf8)!)
        parser.delegate = handler
        parser.parse()
        if let error = parser.parserError {
            throw HTMLAttributedStringParserError.underlying(error: error)
        }

        switch handler.result {
        case .success(let node): return try node.toAttributedString()
        case .failure(let error): throw error
        case .none: throw HTMLAttributedStringParserError.documentUnclosed
        }
    }
}

protocol TagRendererProvider {
    func tagRenderer(forTag name: String) -> (any HTMLTagRenderer)?
}

protocol AttributeRendererProvider {
    func attributeRenderer(forKey key: String, tag tagName: String) -> (any HTMLAttributeRenderer)?
}

extension HTMLAttributedStringParser: TagRendererProvider {
    func tagRenderer(forTag name: String) -> HTMLTagRenderer? {
        tagRenderersIndexedByName[name]
    }
}

extension HTMLAttributedStringParser: AttributeRendererProvider {
    func attributeRenderer(forKey key: String, tag tagName: String) -> HTMLAttributeRenderer? {
        guard let renderer = attributeRenderersIndexedByKey[key],
              renderer.supportedTagNames?.contains(tagName) ?? true
        else { return nil }
        return renderer
    }
}
