//
//  SerialPortManager.swift
//  PicoCanvas
//
//  Created by Jinghan Wang on 11/27/21.
//

import Foundation
import ORSSerial

protocol SerialPortManagerDelegate: AnyObject {
    func serialPortDidOpen()
    func serialPortDidClose()
}

class SerialPortManager: NSObject {
    static let shared = SerialPortManager()
    
    private let kPortIdentifier = "usb"
    private var serialPort: ORSSerialPort?
    weak var delegate: SerialPortManagerDelegate?
    
    private override init() {
        super.init()
    }
    
    func refresh() {
        if let port = serialPort {
            port.close()
            serialPort = nil
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.setupSerialPort()
        }
    }
}


extension SerialPortManager {
    private func setupSerialPort() {
        
        guard let port = ORSSerialPortManager.shared().availablePorts.first(where: {$0.path.contains(kPortIdentifier)}) else {
            print("Unable to create port!")
            return
        }
        print("Setting up serial port: \(port.path)")
        port.delegate = self
        port.rts = true
        port.dtr = true
        port.open()
        
        self.serialPort = port
    }
}

extension SerialPortManager: ORSSerialPortDelegate {
    func serialPortWasRemovedFromSystem(_ serialPort: ORSSerialPort) {
        print("serialPortWasRemovedFromSystem")
    }
    
    func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) {
        guard !CommandParser.shared.parse(data: data) else { return }
        
        let str = String(data: data, encoding: .utf8) ?? "nil"
        print("didReceive: \(str)")
    }
    
    func serialPort(_ serialPort: ORSSerialPort, didReceiveResponse responseData: Data, to request: ORSSerialRequest) {
        print("responseData")
    }
    
    func serialPort(_ serialPort: ORSSerialPort, didReceivePacket packetData: Data, matching descriptor: ORSSerialPacketDescriptor) {
        guard let string = String(data: packetData, encoding: .utf8) else {
            print("Not able to parse data: \(packetData)"); return
        }
        
        print(string)
    }
    
    func serialPort(_ serialPort: ORSSerialPort, requestDidTimeout request: ORSSerialRequest) {
        print("requestDidTimeout")
    }
    
    func serialPortWasOpened(_ serialPort: ORSSerialPort) {
        delegate?.serialPortDidOpen()
    }
    
    func serialPortWasClosed(_ serialPort: ORSSerialPort) {
        delegate?.serialPortDidClose()
    }
    
    func serialPort(_ serialPort: ORSSerialPort, didEncounterError error: Error) {
        print("error: \(error)")
    }
}
