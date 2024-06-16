//
//  WebCal.swift
//
//  
//  Created by Tomohiro Kumagai on 2024/06/16
//  
//

import Foundation

struct WebCal {
    
    let url: URL
    
    init(url: URL) {
        self.url = url
    }
}

extension WebCal {
    
    init?(_ path: String) {
        
        let path = path.replacing(#/^webcal:///#, with: "https://")
        
        guard let url = URL(string: path) else {
            return nil
        }
        
        self.init(url: url)
    }
    
    var contents: Contents {
        
        get throws {
            try Contents(from: url)
        }
    }
}

