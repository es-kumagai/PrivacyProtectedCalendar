//
//  ContentsLine.swift
//
//  
//  Created by Tomohiro Kumagai on 2024/06/16
//  
//

extension Contents {
    
    struct Line {
        
        let name: String
        let parameter: Parameter
        private(set) var valueComponents: [String]
        fileprivate(set) var scope: String?
    }
}

extension Contents.Line : CustomStringConvertible {
    
    var description: String {
        
        guard !isEmpty else {
            return ""
        }
        
        return "\(name)\(parameter):\(value)"
    }
}

extension Contents.Line {
    
    static func ~= (pattern: (String) -> Bool, value: Self) -> Bool {
        pattern(value.name)
    }
    
    static func ~= (pattern: String, value: Self) -> Bool {
        value.name == pattern
    }
    
    static func ~= (patterns: [Regex<Substring>], value: Self) -> Bool {
        
        for pattern in patterns where try! pattern.firstMatch(in: value.name) != nil {
            return true
        }
        
        return false
    }
    
    init(rawLine: some StringProtocol) throws {
        
        let components = rawLine.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: false)
        let nameComponents = components[0].split(separator: ";", maxSplits: 1, omittingEmptySubsequences: false)
        
        switch (components.count, nameComponents.count) {
            
        case (1, 1):
            name = String(nameComponents[0])
            parameter = Parameter(rawValue: "")
            valueComponents = []
            
        case (1, 2):
            name = String(nameComponents[0])
            parameter = Parameter(rawValue: nameComponents[1])
            valueComponents = []
            
        case (2, 1):
            name = String(nameComponents[0])
            parameter = Parameter(rawValue: "")
            valueComponents = [String(components[1])]
       
        case (2, 2):
            name = String(nameComponents[0])
            parameter = Parameter(rawValue: nameComponents[1])
            valueComponents = [String(components[1])]

        default:
            print(rawLine)
            throw ContentsError("Unexpected line found.")
        }
    }
    
    var value: String {
        valueComponents.joined(separator: Contents.newline)
    }
    
    var isEmpty: Bool {
        name.isEmpty && parameter.isEmpty && valueComponents.isEmpty
    }
    
    mutating func appendValue(_ value: some StringProtocol) {
        self.valueComponents.append(String(value))
    }
    
    consuming func appendingValue(_ value: some StringProtocol) -> Contents.Line {
        
        appendValue(value)
        return self
    }
    
    borrowing func replacingValue(with value: some StringProtocol) -> Contents.Line {
        replacingValue(with: [value])
    }
    
    borrowing func replacingValue(with value: some Sequence<some StringProtocol>) -> Contents.Line {
        Contents.Line(name: name, parameter: parameter, valueComponents: Array(value.map(String.init(_:))), scope: scope)
    }
}

extension MutableCollection<Contents.Line> {
    
    consuming func assigningScopes() throws -> Self {
        
        try assignScopes()
        return self
    }
    
    mutating func assignScopes() throws {
        
        var currentScopes: [String] = []
        
        for index in indices {
            
            switch self[index].name {
                
            case "BEGIN":
                currentScopes.append(self[index].value)
                
            case "END" where currentScopes.isEmpty:
                throw ContentsError("Unexpected end header found: \(self)")
                
            case "END":
                currentScopes.removeLast()
                
            default:
                break
            }
            
            self[index].scope = currentScopes.last
        }
    }
}

extension BidirectionalCollection<Contents.Line> where Self : MutableCollection, Self : RangeReplaceableCollection {
    
    @discardableResult
    mutating func appendRawLine(_ rawLine: some StringProtocol, checkStrictly: Bool, scope: String?) throws -> Contents.Line {
        
        if try Contents.isContinuationRawLine(rawLine, checkStrictly: checkStrictly, scope: scope) {
            
            let line = removeLast().appendingValue(rawLine)
            append(line)
            
            return line
        } else {
            
            let line = try Contents.Line(rawLine: rawLine)
            append(line)
            
            return line
        }
    }
}
