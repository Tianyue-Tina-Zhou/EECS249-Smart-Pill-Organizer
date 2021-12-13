//
//  OrientationManager.swift
//  PicoCanvas
//
//  Created by Jinghan Wang on 12/7/21.
//

import Foundation

class OrientationManager {
    static let shared = OrientationManager()
    
    private init() {}
    
    func calculateDelta(base: DeviceOrientation, orientation: DeviceOrientation) -> DeviceOrientation {
        let roll = calculateDelta(start: base.roll, end: orientation.roll)
        let pitch = calculateDelta(start: base.pitch, end: orientation.pitch)
        let yaw = calculateDelta(start: base.yaw, end: orientation.yaw)
        
        return DeviceOrientation(roll: roll, pitch: pitch, yaw: yaw)
    }
}

extension OrientationManager {
    private func calculateDelta(start: Double, end: Double) -> Double {
        let delta = end - start
        if delta > 180 {
            return delta - 360
        }
        
        if delta < -180 {
            return delta + 360
        }
        
        return delta
    }
}
