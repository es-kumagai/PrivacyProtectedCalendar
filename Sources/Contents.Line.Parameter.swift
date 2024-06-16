//
//  Contents.Line.Parameter.swift
//
//  
//  Created by Tomohiro Kumagai on 2024/06/16
//  
//

extension Contents.Line {
    
    struct Parameter {
        
        let rawValue: String
        
        init(rawValue: some StringProtocol) {
            self.rawValue = String(rawValue)
        }
    }
}

extension Contents.Line.Parameter : CustomStringConvertible {
    
    var description: String {
        
        guard !isEmpty else {
            return ""
        }

        return ";\(rawValue)"
    }
}

extension Contents.Line.Parameter {
    
    var isEmpty: Bool {
        rawValue.isEmpty
    }
}
