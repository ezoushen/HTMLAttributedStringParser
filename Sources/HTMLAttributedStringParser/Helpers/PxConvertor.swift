//
//  PxConvertor.swift
//  
//
//  Created by EZOU on 2022/9/11.
//

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

enum PxConvertor {
    static func toPoint(value: String) -> CGFloat? {
        if value.hasSuffix("px") {
            if let size = Double(String(value.dropLast(2))) {
                return CGFloat(size)
            } else {
                return nil
            }
        }
        if let double = Double(value) {
            return CGFloat(double)
        }
        return nil
    }
}
