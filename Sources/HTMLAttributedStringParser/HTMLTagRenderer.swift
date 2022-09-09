//
//  HTMLTagRenderer.swift
//  
//
//  Created by EZOU on 2022/9/11.
//

import Foundation

public protocol HTMLTagRenderer {
    var tagName: String { get }

    func render(
        string: NSMutableAttributedString,
        attributes: [String: String],
        derivedAttributes: [NSAttributedString.Key: Any]?) throws
}
