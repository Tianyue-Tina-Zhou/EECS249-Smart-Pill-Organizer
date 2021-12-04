//
//  DataProvider.swift
//  PicoCanvas
//
//  Created by Jinghan Wang on 11/27/21.
//

import Foundation

struct ControlPacket {
    let speedX: Float
    let speedY: Float
    let stroke: Bool
}

protocol ControlPacketProviderDelegate: AnyObject {
    func didReceiveNewControlPacket(packet: ControlPacket)
}

protocol ControlPacketProviderProtocol: AnyObject {
    var delegate: ControlPacketProviderDelegate? { get set }
}

class ControlPacketProviderStub: ControlPacketProviderProtocol {
    weak var delegate: ControlPacketProviderDelegate?
    
    private let triggerInterval: TimeInterval = 0.02
    var timer: Timer?
    var count = 0;
    
    
    func start() {
        stop()
        
        timer = .scheduledTimer(withTimeInterval: triggerInterval, repeats: true, block: { [weak self] _ in
            self?.timerDidFire()
        })
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    private func timerDidFire() {
        count = (count + 1) % 100
        let packet: ControlPacket
        if count < 25 {
            packet = .init(speedX: 5000, speedY: 0, stroke: true)
        } else if count < 50 {
            packet = .init(speedX: 0, speedY: 5000, stroke: false)
        } else if count < 75 {
            packet = .init(speedX: -5000, speedY: 0, stroke: true)
        } else {
            packet = .init(speedX: 0, speedY: -5000, stroke: true)
        }
        
        delegate?.didReceiveNewControlPacket(packet: packet)
    }
}
