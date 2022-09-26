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
    /// Support only hex style color string for now
    convenience init?(cssStyle string: String) {
        /// Hex style
        if string.hasPrefix("#") {
            let numberString: String = String(string.dropFirst())
            guard numberString.isValidHexNumber(),
                  let number = UInt32(numberString, radix: 16)
            else { return nil }
            switch numberString.count {
            case 6: self.init(rgb: number)
            case 8: self.init(argb: (number >> 8) | ((number & 0xFF) << 24))
            default: return nil
            }
        } else {
            return nil
        }
    }

    convenience init(rgb color: UInt32) {
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

private extension String {
    func isValidHexNumber() -> Bool {
        guard isEmpty == false else { return false }
        let chars = CharacterSet(charactersIn: "0123456789ABCDEF").inverted
        return uppercased().rangeOfCharacter(from: chars) == nil
    }
}
