//
//  Canvas.swift
//  PicoCanvas
//
//  Created by Jinghan Wang on 11/27/21.
//

import Foundation
import AppKit


typealias CanvasRelativeCoordinate = CGPoint

struct CanvasConfig {
    var backgroundColor: NSColor = .lightGray
    var cursorColor: NSColor = .black
    var cursorSize = CGSize(width: 15, height: 15)
    var trackingSpeed: Double = 0.01
    
    static let `default` = CanvasConfig()
}

class Canvas: NSView {
    private var cursorPosition: CanvasRelativeCoordinate = CanvasRelativeCoordinate(x: 0.25, y: 0.25)
    private let config: CanvasConfig = .default
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureViews()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        config.backgroundColor.setFill()
        dirtyRect.fill()
        
        drawCursorPosition()
    }
}

extension Canvas {
    func update(controlPacket: ControlPacket) {
        let old = cursorPosition
        cursorPosition.x += CGFloat(controlPacket.speedX) * CGFloat(config.trackingSpeed)
        cursorPosition.y += CGFloat(controlPacket.speedY) * CGFloat(config.trackingSpeed)
        
        guard cursorPosition != old else { return }
        setNeedsDisplay(bounds)
    }
}

extension Canvas {
    private func configureViews() {
        
    }
    
    private func drawCursorPosition() {
        let cursorRect = CGRect(origin: translateToAbsolut(relative: cursorPosition), size: config.cursorSize)
        config.cursorColor.setFill()
        cursorRect.fill()
    }
}

extension Canvas {
    private func translateToAbsolut(relative: CGPoint) -> CGPoint {
        return CGPoint(x: frame.width * relative.x, y: frame.height * relative.y)
    }
}
