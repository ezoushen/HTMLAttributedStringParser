//
//  Color.swift
//  
//
//  Created by EZOU on 2022/9/9.
//


#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
typealias Color = UIColor
#elseif os(macOS)
import AppKit
typealias Color = NSColor
#endif

extension Color {
    convenience init?(hexString: String) {
        guard hexString.starts(with: "#"),
              let number = UInt32(hexString.dropFirst(), radix: 16)
        else { return nil }

        self.init(hex: number)
    }

    convenience init(hex color: UInt32) {
        self.init(argb: 0xFF000000 | color)
    }

    convenience init(argb color: UInt32) {
        let mask = 0xFF

        let a = Int(color >> 24) & mask
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask

        let alpha = CGFloat(a) / 255.0
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
