//
//  Font.swift
//  
//
//  Created by EZOU on 2022/9/9.
//

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
public typealias Font = UIFont
#elseif os(macOS)
import AppKit
public typealias Font = NSFont
#endif

open class FontProvider {
    public init() { }
    
    open func createFont(name: String?, ofSize size: CGFloat?, weight: Int?) -> Font {
        if let name = name,
           let font = Font(
            name: composeFontName(family: name, style: fontStyle(number: weight)),
            size: size ?? 14.0)
        {
            return font
        } else {
            return .systemFont(
                ofSize: size ?? 14.0,
                weight: fontWeight(number: weight))
        }
    }

    open func fontWeight(number: Int?) -> Font.Weight {
        switch number {
        case 300: return .light
        case 500: return .medium
        case 600: return .semibold
        case 700: return .bold
        case 800: return .black
        case 900: return .heavy
        default:  return .regular
        }
    }

    open func fontStyle(number: Int?) -> String {
        switch number {
        case 300: return "Light"
        case 500: return "Medium"
        case 600: return "Semibold"
        case 700: return "Bold"
        case 800: return "Black"
        case 900: return "Heavy"
        default:  return ""
        }
    }

    open func composeFontName(family: String, style: String) -> String {
        style.isEmpty ? family : "\(family)-\(style)"
    }
}
