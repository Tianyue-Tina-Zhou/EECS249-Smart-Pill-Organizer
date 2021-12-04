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
    var backgroundColor: NSColor = .darkGray
    var cursorColor: NSColor = .white
    var cursorSize = CGSize(width: 15, height: 15)
    var trackingSpeed: Double = 0.001
    
    static let `default` = CanvasConfig()
}

class Canvas: NSView {
    private var cursorPosition: CGPoint = .zero
    private let config: CanvasConfig = .default
    private let manager = DrawingManager()
    private var lastControlPacket: ControlPacket? = nil
    
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
        
        drawCursor()
        drawStrokes()
    }
    
    private func calculateCursorRect(origin: CGPoint) -> CGRect {
        var cursorRect = CGRect(origin: origin, size: config.cursorSize)
        cursorRect.origin.x -= config.cursorSize.width / 2
        cursorRect.origin.y -= config.cursorSize.height / 2
        return cursorRect
    }
    
    private func drawCursor() {
        config.cursorColor.setFill()
        calculateCursorRect(origin: cursorPosition).fill()
    }
    
    private func drawStrokes() {
        guard let context: CGContext = NSGraphicsContext.current?.cgContext else { return }
        
        for item in manager.drawItems {
            context.setLineCap(.round)
            context.setLineJoin(.round)
            context.setLineWidth(item.brush.width)
            context.setStrokeColor(item.brush.color.systemColor.cgColor)
            context.addPath(item.path)
            context.strokePath()
        }
    }
}

extension Canvas {
    func update(controlPacket: ControlPacket) {
        defer { lastControlPacket = controlPacket }
        
        let oldRect = calculateCursorRect(origin: cursorPosition)
        guard controlPacket.speedX != 0 || controlPacket.speedY != 0 else { return }
        cursorPosition.x += CGFloat(controlPacket.speedX) * CGFloat(config.trackingSpeed)
        cursorPosition.y += CGFloat(controlPacket.speedY) * CGFloat(config.trackingSpeed)
        let newRect = calculateCursorRect(origin: cursorPosition)
        setNeedsDisplay(oldRect)
        setNeedsDisplay(newRect)
        
        if controlPacket.stroke {
            if let lastControlPacket = lastControlPacket, lastControlPacket.stroke == true {
                manager.strokeMoved(position: cursorPosition)
            } else {
                manager.strokeBegan(position: cursorPosition)
            }
        }
    }
    
    func undo() {
        manager.undo()
    }
}

extension Canvas {
    private func configureViews() {
        manager.delegate = self
        cursorPosition = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
    }
}

extension Canvas: DrawingManagerDelegate {
    func manager(_ manager: DrawingManager, requireUpdateDisplay boundingBox: CGRect?) {
        if let box = boundingBox {
            setNeedsDisplay(box)
        } else {
            setNeedsDisplay(bounds)
        }
    }
}
