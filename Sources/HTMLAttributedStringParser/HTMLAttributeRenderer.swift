//
//  HTMLAttributeRenderer.swift
//  
//
//  Created by EZOU on 2022/9/11.
//

import Foundation

public protocol HTMLAttributeRenderer {
    /// Attribute name
    var key: String { get }
    /// Return nil if supporting all tag names
    var supportedTagNames: Set<String>? { get }

    func render(value: String) throws -> [NSAttributedString.Key: Any]?
}
