//
//  CommandParser.swift
//  PicoCanvas
//
//  Created by Jinghan Wang on 11/27/21.
//

import Foundation
import Cocoa

protocol CommandParserDelegate: AnyObject {
    func didRecieveNewCommand(command: Command)
}

struct DeviceOrientation {
    let roll: Double
    let pitch: Double
    let yaw: Double
}

enum CommandType: Int {
    case rgb = 0
    case penMove
    case undo
    case angle
}

enum Command {
    case rgb(color: NSColor)
    case penMove(x: Int, y: Int, stroke: Bool)
    case undo
    case angle(orientation: DeviceOrientation, stroke: Bool)
    
    init?(string: String) {
        let args = string.components(separatedBy: " ")
        guard args.count >= 1 else { return nil }
        guard let rawValue = Int(args[0]), let type = CommandType(rawValue: rawValue) else { return nil }
        
        switch type {
        case .rgb:
            guard args.count == 2 else { return nil }
            guard args[1].count == 6 else { return nil }
            self = .rgb(color: NSColor(hex: args[1]))
        case .penMove:
            guard args.count == 4 else { return nil }
            guard let stroke = Int(args[1]), let x = Int(args[2]), let y = Int(args[3]) else { return nil }
            self = .penMove(x: x, y: y, stroke: stroke != 0)
        case .undo:
            self = .undo
        case .angle:
            guard args.count == 5 else { return nil }
            guard let stroke = Int(args[1]), let roll = Double(args[2]), let pitch = Double(args[3]), let yaw = Double(args[4]) else { return nil }
            guard !roll.isNaN && !pitch.isNaN && !yaw.isNaN else { return nil }
            let orientation = DeviceOrientation(roll: roll, pitch: pitch, yaw: yaw)
            self = .angle(orientation: orientation, stroke: stroke != 0)
        }
    }
}

class CommandParser {
    static let shared = CommandParser()
    private let kCommandPrefix = "<C>"
    private let kCommandSuffix = "</C>"
    weak var delegate: CommandParserDelegate?
    
    var didRecieveNewCommand: ((String) -> Void)?
    
    private init() {}
    
    func parse(data: Data) -> Bool {
        guard let rawCommand = String(data: data, encoding: .utf8) else { return false }
        guard rawCommand.hasPrefix(kCommandPrefix) else { return false }
        guard rawCommand.hasSuffix(kCommandSuffix) else { return false }
        
        var result = rawCommand
        result.removeFirst(kCommandPrefix.count)
        result.removeLast(kCommandSuffix.count)
        
        guard let command = Command(string: result) else { return false }
        print("Command: \(command)")
        
        delegate?.didRecieveNewCommand(command: command)
        
        return true
    }
}
