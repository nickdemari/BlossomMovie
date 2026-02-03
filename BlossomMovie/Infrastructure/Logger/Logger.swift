//
//  Logger.swift
//  BlossomMovie
//
//  Created by Nick Demari on 1/4/26.
//

import Foundation
import os.log

/// Logging levels
enum LogLevel: Int, CaseIterable {
    case verbose = 0
    case debug = 1
    case info = 2
    case warning = 3
    case error = 4
    
    var emoji: String {
        switch self {
        case .verbose: return "💬"
        case .debug: return "🐛"
        case .info: return "ℹ️"
        case .warning: return "⚠️"
        case .error: return "❌"
        }
    }
    
    var osLogType: OSLogType {
        switch self {
        case .verbose, .debug: return .debug
        case .info: return .info
        case .warning: return .error
        case .error: return .fault
        }
    }
}

/// Logger protocol
protocol LoggerProtocol {
    func log(_ message: String, level: LogLevel)
    func verbose(_ message: String)
    func debug(_ message: String)
    func info(_ message: String)
    func warning(_ message: String)
    func error(_ message: String)
}

/// Production logger implementation using os.log
final class Logger: LoggerProtocol {
    
    // MARK: - Properties
    private let osLog: OSLog
    private let subsystem: String
    private let category: String
    private let minimumLogLevel: LogLevel
    
    // MARK: - Initialization
    init(
        subsystem: String = Bundle.main.bundleIdentifier ?? "BlossomMovie",
        category: String = "General",
        minimumLogLevel: LogLevel = .debug
    ) {
        self.subsystem = subsystem
        self.category = category
        self.minimumLogLevel = minimumLogLevel
        self.osLog = OSLog(subsystem: subsystem, category: category)
    }
    
    // MARK: - LoggerProtocol Implementation
    func log(_ message: String, level: LogLevel) {
        guard level.rawValue >= minimumLogLevel.rawValue else { return }
        
        let formattedMessage = "\(level.emoji) [\(category)] \(message)"
        
        #if DEBUG
        print(formattedMessage)
        #endif
        
        os_log("%{public}@", log: osLog, type: level.osLogType, formattedMessage)
    }
    
    func verbose(_ message: String) {
        log(message, level: .verbose)
    }
    
    func debug(_ message: String) {
        log(message, level: .debug)
    }
    
    func info(_ message: String) {
        log(message, level: .info)
    }
    
    func warning(_ message: String) {
        log(message, level: .warning)
    }
    
    func error(_ message: String) {
        log(message, level: .error)
    }
}

/// Mock logger for testing
final class MockLogger: LoggerProtocol {
    private(set) var loggedMessages: [(message: String, level: LogLevel)] = []
    
    func log(_ message: String, level: LogLevel) {
        loggedMessages.append((message, level))
    }
    
    func verbose(_ message: String) { log(message, level: .verbose) }
    func debug(_ message: String) { log(message, level: .debug) }
    func info(_ message: String) { log(message, level: .info) }
    func warning(_ message: String) { log(message, level: .warning) }
    func error(_ message: String) { log(message, level: .error) }
    
    func clearLogs() {
        loggedMessages.removeAll()
    }
}
