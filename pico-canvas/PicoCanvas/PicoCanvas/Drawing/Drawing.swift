//
//  Drawing.swift
//  PicoCanvas
//
//  Created by Jinghan Wang on 12/4/21.
//

import Foundation
import AppKit

struct DrawItem {
    var path: CGMutablePath
    var brush: Brush
}

struct Color : Codable, Equatable {
    let red: CGFloat
    let green: CGFloat
    let blue: CGFloat
    
    static let white = Color(red: 1, green: 1, blue: 1)
    
    var systemColor: NSColor {
        return NSColor(deviceRed: red, green: green, blue: blue, alpha: 1)
    }
}

enum BlendMode: String, Codable {
    case normal = "normal"
    case clear = "clear"
    
    var cgBlendMode: CGBlendMode {
        switch self {
        case .normal:
            return .normal
        case .clear:
            return .clear
        }
    }
}

struct Brush: Codable {
    var color: Color
    var width: CGFloat
    
    
    init(color: Color, width: CGFloat = 3) {
        self.color = color
        self.width = width
    }
    
    // MARK: - Static brushes
    
    public static var `default`: Brush {
        return Brush(color: .white, width: 6)
    }
}

extension Brush: Equatable, Comparable, CustomStringConvertible {
    
    public static func ==(lhs: Brush, rhs: Brush) -> Bool {
        return (
          lhs.color == rhs.color && lhs.width == rhs.width
        )
    }
    
    public static func <(lhs: Brush, rhs: Brush) -> Bool {
        return (
            lhs.width < rhs.width
        )
    }
    
    public var description: String {
        return "<Brush: color: \(color), width: \(width)>"
    }
}

extension NSColor {
    convenience init(hex: String) {
        var hex = hex
        if hex.hasPrefix("0x") {
            hex.removeFirst(2)
        } else if hex.hasPrefix("#") {
            hex.removeFirst(1)
        }

        guard let value = Int(hex, radix: 16) else {
            self.init(); return
        }

        switch hex.count {
        case 3:
            self.init(hex3: value, alpha: 1)
        case 6:
            self.init(hex6: value, alpha: 1)
        default:
            self.init()
        }
    }
    
    private convenience init(hex3: Int, alpha: CGFloat) {
        let r = (hex3 & 0xF00) >> 8
        let g = (hex3 & 0x0F0) >> 4
        let b = (hex3 & 0x00F) >> 0
        
        self.init(red256:   (r << 4) + r,
                  green256: (g << 4) + g,
                  blue256:  (b << 4) + b,
                  alpha: alpha)
    }
    
    private convenience init(hex6: Int, alpha: CGFloat) {
        self.init(red256:   (hex6 & 0xFF0000) >> 16,
                  green256: (hex6 & 0x00FF00) >> 8,
                  blue256:  (hex6 & 0x0000FF) >> 0,
                  alpha: alpha)
    }
    
    private convenience init(red256: Int, green256: Int, blue256: Int, alpha: CGFloat) {
        self.init(red:   CGFloat(red256)   / 255.0,
                  green: CGFloat(green256) / 255.0,
                  blue:  CGFloat(blue256)  / 255.0,
                  alpha: alpha)
    }
}
