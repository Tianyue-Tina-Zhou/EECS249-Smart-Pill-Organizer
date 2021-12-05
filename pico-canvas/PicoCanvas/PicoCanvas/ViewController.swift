//
//  ViewController.swift
//  PicoCanvas
//
//  Created by Jinghan Wang on 11/27/21.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet var refreshButton: NSButton?
    @IBOutlet var undoButton: NSButton?
    @IBOutlet var colorButton: NSButton?
    @IBOutlet var clearButton: NSButton?
    @IBOutlet var recenterButton: NSButton?
    @IBOutlet var stackView: NSStackView?
    
    @IBOutlet var canvas: Canvas?
    @IBOutlet var colorIndicatorView: NSView?
    @IBOutlet var colorIndicatorViewBorder: NSView?
    
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
        recenterButton?.action = #selector(didClickReCenterButton)
        clearButton?.action = #selector(didClickClearButton)
        
        colorIndicatorView?.wantsLayer = true
        colorIndicatorView?.rotate(byDegrees: 45)
        colorIndicatorView?.layer?.backgroundColor = .white
        
        colorIndicatorViewBorder?.wantsLayer = true
        colorIndicatorViewBorder?.rotate(byDegrees: 45)
        colorIndicatorViewBorder?.alphaValue = 0.7
        colorIndicatorViewBorder?.layer?.backgroundColor = .white
        
        if let item = NSApplication.shared.mainMenu?.items.last?.submenu?.items.last {
            item.target = self
            item.action = #selector(didClickToggleButtons)
        }
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
        update(color: colorPanel.color)
    }
    
    @objc
    func didClickClearButton() {
        guard let canvas = canvas else { return }
        canvas.clear()
    }
    
    @objc
    func didClickReCenterButton() {
        guard let canvas = canvas else { return }
        canvas.recenter()
    }
    
    @objc
    func didClickToggleButtons() {
        guard let stackView = stackView else { return }
        stackView.isHidden = !stackView.isHidden
    }
}

extension ViewController: SerialPortManagerDelegate {
    func serialPortDidOpen() {
        print("Pico Connected")
    }
    
    func serialPortDidClose() {
        print("Pico Disconnected")
    }
}

extension ViewController: CommandParserDelegate {
    func didRecieveNewCommand(command: Command) {
        guard let canvas = canvas else { return }
        switch command {
        case .rgb(let color):
            update(color: color)
        case .penMove(let x, let y, let stroke):
            let packet = ControlPacket(speedX: Float(x), speedY: Float(y), stroke: stroke)
            canvas.update(controlPacket: packet)
        case .undo:
            canvas.undo()
        }
    }
    
    private func update(color: NSColor) {
        guard let canvas = canvas else { return }
        let color = color.withAlphaComponent(1)
        canvas.setCursorColor(color: color)
        colorIndicatorView?.layer?.backgroundColor = color.cgColor
        colorIndicatorViewBorder?.layer?.backgroundColor = color.cgColor
    }
}
