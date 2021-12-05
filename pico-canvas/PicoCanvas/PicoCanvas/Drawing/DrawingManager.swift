//
//  DrawingManager.swift
//  PicoCanvas
//
//  Created by Jinghan Wang on 12/4/21.
//

import Foundation

protocol DrawingManagerDelegate: AnyObject {
    func manager(_ manager: DrawingManager, requireUpdateDisplay boundingBox: CGRect?)
}

class DrawingManager {
    // Points
    private var currentPoint: CGPoint = .zero
    private var previousPoint: CGPoint = .zero
    private var previousPreviousPoint: CGPoint = .zero
    private var firstPoint: CGPoint = .zero
    
    // Drawings
    private(set) var drawItems: [DrawItem] = []
    
    // Brush
    var brush: Brush = .default
    var drawingMode: DrawingMode = .freeStroke
    
    weak var delegate: DrawingManagerDelegate?
}

extension DrawingManager {
    enum DrawingMode {
        case freeStroke
    }
}

extension DrawingManager {
    func strokeBegan(position: CGPoint) {
        firstPoint = position
        currentPoint = position
        previousPoint = position
        previousPreviousPoint = position
        
        let newItem = DrawItem(path: createNewPath(), brush: brush)
        drawItems.append(newItem)
    }
    
    func strokeMoved(position: CGPoint) {
        previousPreviousPoint = previousPoint
        previousPoint = currentPoint
        currentPoint = position
        
        switch drawingMode {
        case .freeStroke:
            let newPath = createNewPath()
            guard let currentPath = drawItems.last else { break }
            currentPath.path.addPath(newPath)
        }
    }
    
    func undo() {
        guard !drawItems.isEmpty else { return }
        drawItems.removeLast()
        delegate?.manager(self, requireUpdateDisplay: nil)
    }
    
    func clear() {
        guard !drawItems.isEmpty else { return }
        drawItems.removeAll()
        delegate?.manager(self, requireUpdateDisplay: nil)
    }
}

extension DrawingManager {
    private func createNewPath() -> CGMutablePath {
        let midPoints = getMidPoints()
        let subPath = createSubPath(midPoints.0, mid2: midPoints.1)
        let newPath = addSubPathToPath(subPath)
        return newPath
    }
    
    private func getMidPoints() -> (CGPoint,  CGPoint) {
        let mid1 : CGPoint = calculateMidPoint(previousPoint, p2: previousPreviousPoint)
        let mid2 : CGPoint = calculateMidPoint(currentPoint, p2: previousPoint)
        return (mid1, mid2)
    }
    
    private func createSubPath(_ mid1: CGPoint, mid2: CGPoint) -> CGMutablePath {
        let subpath : CGMutablePath = CGMutablePath()
        subpath.move(to: CGPoint(x: mid1.x, y: mid1.y))
        subpath.addQuadCurve(to: CGPoint(x: mid2.x, y: mid2.y), control: CGPoint(x: previousPoint.x, y: previousPoint.y))
        return subpath
    }
    
    private func addSubPathToPath(_ subpath: CGMutablePath) -> CGMutablePath {
        let bounds : CGRect = subpath.boundingBox
        let drawBox : CGRect = bounds.insetBy(dx: -2.0 * brush.width, dy: -2.0 * brush.width)
        delegate?.manager(self, requireUpdateDisplay: drawBox)
        return subpath
    }
    
    private func calculateMidPoint(_ p1 : CGPoint, p2 : CGPoint) -> CGPoint {
        return CGPoint(x: (p1.x + p2.x) * 0.5, y: (p1.y + p2.y) * 0.5);
    }
}
