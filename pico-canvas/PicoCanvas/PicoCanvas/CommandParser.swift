//
//  CommandParser.swift
//  PicoCanvas
//
//  Created by Jinghan Wang on 11/27/21.
//

import Foundation

protocol CommandParserDelegate: AnyObject {
    func didRecieveNewCommand(command: String)
}

class CommandParser {
    static let shared = CommandParser()
    private let kCommandPrefix = "<C>"
    weak var delegate: CommandParserDelegate?
    
    var didRecieveNewCommand: ((String) -> Void)?
    
    private init() {}
    
    func parse(data: Data) -> Bool {
        guard let rawCommand = String(data: data, encoding: .utf8) else { return false }
        guard rawCommand.hasPrefix(kCommandPrefix) else { return false }
        var result = rawCommand
        result.removeFirst(kCommandPrefix.count)
        
        delegate?.didRecieveNewCommand(command: result)
        
        return true
    }
}
