//
//  XMLParserHandler.swift
//  
//
//  Created by EZOU on 2022/9/11.
//

import Foundation

class XMLParsingHandler: NSObject, XMLParserDelegate {

    private var processingStack: [TaggedHTMLNode] = []

    let tagRendererProvider: any TagRendererProvider
    let attributeRendererProvider: any AttributeRendererProvider

    init(
        tagRendererProvider: any TagRendererProvider,
        attributeRendererProvider: any AttributeRendererProvider)
    {
        self.tagRendererProvider = tagRendererProvider
        self.attributeRendererProvider = attributeRendererProvider
    }

    var result: Result<TaggedHTMLNode, HTMLAttributedStringParserError>!

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        let node = TaggedHTMLNode(tagName: elementName, attributes: attributeDict)
        node.attributeRendererProvider = attributeRendererProvider
        node.tagRendererProvider = tagRendererProvider
        processingStack.append(node)
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        guard let node = processingStack.popLast(), node.tagName == elementName else {
            defer { parser.abortParsing() }
            result = .failure(.processedNodeNotFound)
            return
        }
        if let preNode = processingStack.last {
            preNode.children.append(node)
        } else {
            result = .success(node)
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard let taggedNode = processingStack.last else {
            defer { parser.abortParsing() }
            result = .failure(.parentNodeNotFound)
            return
        }
        taggedNode.children.append(PlainTextHTMLNode(content: string))
    }

    func parserDidEndDocument(_ parser: XMLParser) {
        guard !processingStack.isEmpty else { return }
        result = .failure(.documentUnclosed)
    }
}
