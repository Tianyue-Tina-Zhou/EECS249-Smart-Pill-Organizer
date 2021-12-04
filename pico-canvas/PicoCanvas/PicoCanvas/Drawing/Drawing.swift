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
