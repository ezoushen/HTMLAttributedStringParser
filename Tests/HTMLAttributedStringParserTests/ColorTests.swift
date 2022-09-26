//
//  ColorTests.swift
//  
//
//  Created by EZOU on 2022/9/26.
//

import Foundation
import XCTest

@testable import HTMLAttributedStringParser

class ColorTests: XCTestCase {
    func test_initCssStyle_rgbHexString() {
        let color = Color(cssStyle: "#FF0000")
        let red = Color(red: 1.0, green: 0, blue: 0, alpha: 1.0)
        XCTAssertEqual(color, red)
    }

    func test_initCssStyle_rgbaHexString() {
        let color = Color(cssStyle: "#0000FFFF")
        let blue = Color(red: 0.0, green: 0, blue: 1.0, alpha: 1.0)
        XCTAssertEqual(color, blue)
    }

    func test_initCssStyle_invalidHexString() {
        let color = Color(cssStyle: "#LLL")
        XCTAssertNil(color)
    }

    func test_initHex_rgbHex() {
        let color = Color(rgb: 0xFF0000)
        let red = Color(red: 1.0, green: 0, blue: 0, alpha: 1.0)
        XCTAssertEqual(color, red)
    }

    func test_initHex_argbHex() {
        let color = Color(argb: 0xFF00FF00)
        let green = Color(red: 0.0, green: 1.0, blue: 0, alpha: 1.0)
        XCTAssertEqual(color, green)
    }
}
