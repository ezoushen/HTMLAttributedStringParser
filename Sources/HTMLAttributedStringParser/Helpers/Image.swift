//
//  Image.swift
//  
//
//  Created by EZOU on 2022/9/10.
//

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
public typealias Image = UIImage
#elseif os(macOS)
import AppKit
public typealias Image = NSImage
extension NSImage {
    convenience init?(systemName: String) {
        self.init(systemSymbolName: systemName, accessibilityDescription: nil)
    }
}
#endif
