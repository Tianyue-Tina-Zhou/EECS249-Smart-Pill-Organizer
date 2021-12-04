//
//  ViewController.swift
//  PicoCanvas
//
//  Created by Jinghan Wang on 11/27/21.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet var statusTextField: NSTextField?
    @IBOutlet var refreshButton: NSButton?
    @IBOutlet var canvas: Canvas?
    
    private let packetProvider = ControlPacketProviderStub()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CommandParser.shared.delegate = self
        SerialPortManager.shared.delegate = self
        packetProvider.delegate = self
        
        SerialPortManager.shared.refresh()
        
        configureViews()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

extension ViewController {
    private func configureViews() {
        refreshButton?.action = #selector(didClickRefreshButton)
        packetProvider.start()
    }
    
    @objc
    private func didClickRefreshButton() {
        SerialPortManager.shared.refresh()
    }
}

extension ViewController: SerialPortManagerDelegate {
    func serialPortDidOpen() {
        statusTextField?.stringValue = "Pico Connected"
    }
    
    func serialPortDidClose() {
        statusTextField?.stringValue = "Pico Disconnected"
    }
}

extension ViewController: CommandParserDelegate {
    func didRecieveNewCommand(command: Command) {
        statusTextField?.stringValue = "\(command)"
    }
}

extension ViewController: ControlPacketProviderDelegate {
    func didReceiveNewControlPacket(packet: ControlPacket) {
        canvas?.update(controlPacket: packet)
    }
}
