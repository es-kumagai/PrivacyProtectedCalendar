//
//  Contents.swift
//  
//  
//  Created by Tomohiro Kumagai on 2024/06/16
//  
//

import Foundation

struct Contents {
    
    let lines: [Line]
}

extension Contents : Sequence {
    
    func makeIterator() -> PrivacyProtectedLineIterator {
        
        do {
            return try PrivacyProtectedLineIterator(lines: lines)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}

extension Contents {

    static let newline = "\r\n"
    static let nonStricktlyCheckingNames = [
        "DESCRIPTION",
        "X-APPLE-STRUCTURED-LOCATION",
    ]

    static func specialCaseOfContinuationRawLine(_ rawLine: some StringProtocol) -> Bool {

        //
        if rawLine.hasPrefix(" \u{3099}") {
            return true
        }

        if rawLine.hasPrefix("\u{3099}") {
            return true
        }
        
        return false
    }
    
    static func isContinuationRawLine(_ rawLine: some StringProtocol, checkStrictly: Bool, scope: String?) throws -> Bool {
        
        let rawLine = String(rawLine)
        
        if rawLine.isEmpty {
            return false
        }
        
        let continuationPattern = #/^[\w-]+(?:\:|;)/#

        if try continuationPattern.firstMatch(in: rawLine) != nil {
            return false
        }
        
        if rawLine.hasPrefix(" ") {
            return true
        }
        
        guard !checkStrictly else {
            throw ContentsError("Unexpected line format: \(rawLine) (Scope: \(scope ?? ""))")
        }
        
        if specialCaseOfContinuationRawLine(rawLine) {
            return true
        }

        // 甘いチェックの場合は、不明なものは全て継続行として扱います。
        return true
    }
    
    init(from url: URL) throws {
        try self.init(String(contentsOf: url))
    }
    
    init(_ contents: String) throws {
        
        lines = try contents
            .precomposedStringWithCanonicalMapping
            .split(separator: Self.newline, omittingEmptySubsequences: false)
            .reduce(into: (lines: [Line](), previousName: "")) { partialResult, rawLine in

                let previousName = partialResult.previousName
                let checkStrictly = !Self.nonStricktlyCheckingNames.contains(previousName)
                    
                let appendedLine = try partialResult.lines.appendRawLine(rawLine, checkStrictly: checkStrictly, scope: previousName)
                
                partialResult.previousName = appendedLine.name
            }
            .lines
            .assigningScopes()
    }
}
