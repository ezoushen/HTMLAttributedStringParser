//
//  ImgHTMLTagRenderer.swift
//  
//
//  Created by EZOU on 2022/9/11.
//

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

open class ImgHTMLTagRenderer: HTMLTagRenderer {
    public var tagName: String {
        "img"
    }

    public func render(
        string: NSMutableAttributedString,
        attributes: [String: String],
        derivedAttributes: [NSAttributedString.Key: Any]?) throws
    {
        guard let src = attributes["src"] else {
            throw HTMLAttributedStringParserError
                .requiredAttributeNotFound(name: "src")
        }
        if let image = createImage(src: src) {
            let attachment = NSTextAttachment()
            attachment.image = image
            let width: CGFloat = {
                guard let string = attributes["width"],
                      let width = PxConvertor.toPoint(value: string)
                else { return image.size.width }
                return CGFloat(width)
            }()
            let height: CGFloat = {
                guard let string = attributes["height"],
                      let height = PxConvertor.toPoint(value: string)
                else { return image.size.height }
                return CGFloat(height)
            }()
            let x: CGFloat = {
                guard let string = attributes["x"],
                      let x = PxConvertor.toPoint(value: string) else { return 0 }
                return CGFloat(x)
            }()
            let y: CGFloat = {
                guard let string = attributes["y"],
                      let y = PxConvertor.toPoint(value: string) else { return 0 }
                return CGFloat(y)
            }()
            attachment.bounds.origin = CGPoint(x: x, y: y)
            attachment.bounds.size = CGSize(width: width, height: height)
            let imageAttachment = NSMutableAttributedString(attachment: attachment)
            if let derivedAttributes = derivedAttributes {
                imageAttachment.addAttributes(
                    derivedAttributes,
                    range: NSRange(location: 0, length: imageAttachment.length))
            }
            string.append(imageAttachment)
        }
    }

    func createImage(src: String) -> Image? {
        if let url = URL(string: src), let data = try? Data(contentsOf: url) {
            guard let image = Image(data: data) else {
                return nil
            }
            return image
        }
        if src.starts(with: "systemName/") {
            return Image(systemName: String(src.dropFirst("systemName/".count)))
        } else if src.starts(with: "name/") {
            return Image(named: String(src.dropFirst("name/".count)))
        }
        return nil
    }
}
