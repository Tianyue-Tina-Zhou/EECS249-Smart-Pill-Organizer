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
    var cursorSize = CGSize(width: 40, height: 40)
    var cursorPenUpScale: Double = 1
    var cursorPenDownScale: Double = 0.5
    var cursorPenUpAlpha: Double = 0.3
    var cursorPenDownAlpha: Double = 0.8
    var cursorAnimationDuration: TimeInterval = 0.2
    var trackingSpeed: Double = 0.001
    
    static let `default` = CanvasConfig()
}

class Canvas: NSView {
    private var cursorPosition: CGPoint = .zero {
        didSet { updateCursorFrame() }
    }
    private var lastStroke: Bool = false {
        didSet { animateStrokeChange(old: oldValue, new: lastStroke) }
    }
    
    private var config: CanvasConfig = .default
    private let manager = DrawingManager()
    private let cursorView = NSView()
    
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
        drawStrokes()
    }
    
    private func calculateCursorRect(origin: CGPoint) -> CGRect {
        var cursorRect = CGRect(origin: origin, size: config.cursorSize)
        cursorRect.origin.x -= config.cursorSize.width / 2
        cursorRect.origin.y -= config.cursorSize.height / 2
        return cursorRect
    }
    
    private func drawCursor() {
        guard let context: CGContext = NSGraphicsContext.current?.cgContext else { return }
        let rect = calculateCursorRect(origin: cursorPosition)
        config.cursorColor.setFill()
        context.fillEllipse(in: rect)
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
        guard controlPacket.speedX != 0 || controlPacket.speedY != 0 else { return }
        var cursorPosition = self.cursorPosition
        cursorPosition.x += CGFloat(controlPacket.speedX) * CGFloat(config.trackingSpeed)
        cursorPosition.y += CGFloat(controlPacket.speedY) * CGFloat(config.trackingSpeed)
        
        update(cursorPosition: cursorPosition, stroke: controlPacket.stroke)
    }
    
    func update(cursorPosition: CGPoint, stroke: Bool) {
        defer { lastStroke = stroke }
        
        self.cursorPosition = cursorPosition
        
        if stroke {
            if lastStroke {
                manager.strokeMoved(position: cursorPosition)
            } else {
                manager.strokeBegan(position: cursorPosition)
            }
        }
    }
    
    func undo() {
        manager.undo()
    }
    
    func setCursorColor(color: NSColor) {
        config.cursorColor = color
        manager.brush.color = Color.from(systemColor: color)
        updateCursorColor()
    }
}

extension Canvas {
    private func configureViews() {
        cursorView.wantsLayer = true
        addSubview(cursorView)
        
        cursorView.frame.size = config.cursorSize
        if let layer = cursorView.layer {
            layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            layer.contentsGravity = .center
            layer.cornerRadius = config.cursorSize.width / 2
            layer.opacity = 0.5
        }
        
        manager.delegate = self
        cursorPosition = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        
        updateCursorFrame()
        updateCursorColor()
    }
    
    private func updateCursorFrame() {
        cursorView.frame = calculateCursorRect(origin: cursorPosition)
    }
    
    private func updateCursorColor() {
        cursorView.layer?.backgroundColor = config.cursorColor.cgColor
    }
    
    private func animateStrokeChange(old: Bool, new: Bool) {
        guard old != new else { return }
        guard let layer = cursorView.layer else { return }
        
        let scaleStart = new ? config.cursorPenUpScale : config.cursorPenDownScale
        let scaleEnd = new ? config.cursorPenDownScale : config.cursorPenUpScale
        let alphaStart = new ? config.cursorPenUpAlpha : config.cursorPenDownAlpha
        let alphaEnd = new ? config.cursorPenDownAlpha : config.cursorPenUpAlpha

        let scaleAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.transform))
        scaleAnimation.fromValue = calculateTransformation(scale: scaleStart)
        scaleAnimation.toValue = calculateTransformation(scale: scaleEnd)

        let alphaAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
        alphaAnimation.fromValue = alphaStart
        alphaAnimation.toValue = alphaEnd

        let group = CAAnimationGroup()
        group.duration = config.cursorAnimationDuration
        group.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        group.repeatCount = 1
        group.fillMode = .forwards
        group.isRemovedOnCompletion = false
        group.animations = [scaleAnimation, alphaAnimation]

        layer.add(group, forKey: "cursor")
    }
    
    private func calculateTransformation(scale: Double) -> CATransform3D {
        var transform = CATransform3DIdentity
        transform = CATransform3DTranslate(transform, config.cursorSize.width / 2, config.cursorSize.height / 2, 0)
        transform = CATransform3DScale(transform, scale, scale, 1)
        transform = CATransform3DTranslate(transform, -config.cursorSize.width / 2, -config.cursorSize.height / 2, 0)
        return transform
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
