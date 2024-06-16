//
//  ContentsError.swift
//
//  
//  Created by Tomohiro Kumagai on 2024/06/16
//  
//

import Foundation

struct ContentsError : Error, CustomStringConvertible {
    
    let description: String
    
    init(_ description: String) {
        self.description = description
    }
}

extension ContentsError : LocalizedError {
    
    var errorDescription: String? {
        description
    }
}
