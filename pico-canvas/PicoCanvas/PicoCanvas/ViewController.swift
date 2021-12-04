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
    @IBOutlet var undoButton: NSButton?
    @IBOutlet var colorButton: NSButton?
    @IBOutlet var canvas: Canvas?
    private var lastCursor: CGPoint = .zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CommandParser.shared.delegate = self
        SerialPortManager.shared.delegate = self
        
        SerialPortManager.shared.refresh()
        
        configureViews()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

extension ViewController {
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        guard let canvas = canvas else { return }
        lastCursor = CGPoint(x: event.locationInWindow.x, y: event.locationInWindow.y)
        canvas.update(cursorPosition: lastCursor, stroke: true)
    }
    
    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        guard let canvas = canvas else { return }
        canvas.update(cursorPosition: lastCursor, stroke: false)
    }
    
    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        guard let canvas = canvas else { return }
        lastCursor = CGPoint(x: event.locationInWindow.x, y: event.locationInWindow.y)
        canvas.update(cursorPosition: lastCursor, stroke: true)
    }
}

extension ViewController {
    private func configureViews() {
        refreshButton?.action = #selector(didClickRefreshButton)
        undoButton?.action = #selector(didClickUndoButton)
        colorButton?.action = #selector(didClickColorButton)
    }
    
    @objc
    private func didClickRefreshButton() {
        SerialPortManager.shared.refresh()
    }
    
    @objc
    private func didClickUndoButton() {
        canvas?.undo()
    }
    
    @objc
    private func didClickColorButton() {
        let colorPanel = NSColorPanel.shared
        colorPanel.setTarget(self)
        colorPanel.setAction(#selector(didPickColor(sender:)))
        colorPanel.makeKeyAndOrderFront(self)
    }

    @objc
    func didPickColor(sender:AnyObject) {
        guard let colorPanel = sender as? NSColorPanel else { return }
        guard let canvas = canvas else { return }
        
        canvas.setCursorColor(color: colorPanel.color)
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
        guard let canvas = canvas else { return }
        switch command {
        case .rgb(let color):
            canvas.setCursorColor(color: color)
        case .penMove(let x, let y, let stroke):
            let packet = ControlPacket(speedX: Float(x), speedY: Float(y), stroke: stroke)
            canvas.update(controlPacket: packet)
        case .undo:
            canvas.undo()
        }
    }
}
