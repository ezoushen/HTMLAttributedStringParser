//
//  File.swift
//  
//
//  Created by EZOU on 2022/9/11.
//

import Foundation

open class AHTMLTagRenderer: HTMLTagRenderer {
    public var tagName: String {
        "a"
    }

    open func render(
        string: NSMutableAttributedString,
        attributes: [String : String],
        derivedAttributes: [NSAttributedString.Key: Any]?)
    {
        guard let href = attributes["href"],
              let url = URL(string: href) else { return }
        let range = NSRange(location: 0, length: string.length)
        string.addAttribute(.link, value: url, range: range)
    }
}
