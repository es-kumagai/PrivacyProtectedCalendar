//
//  Command.swift
//
//  
//  Created by Tomohiro Kumagai on 2024/06/17
//  
//

import Foundation
import ArgumentParser

@main
struct Command: ParsableCommand {
    
    @Argument
    var address: String
    
    func run() throws {
        
        do {
            let webcal = WebCal(address)!
            let contents = try webcal.contents
            
            print("Content-Type: text/calendar; charset=UTF-8")
            print("")
            
            for line in contents {
                print(line)
            }
        } catch {
            raiseInternalServerError(error.localizedDescription)
        }
    }
}

extension Command {
    
    func raiseInternalServerError(_ description: String) {
        
        print("Status: 500 Internal Server Error")
        print("Content-type: text/html")
        print("")
        print("""
        <html>
            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
                <title>500 Internal Server Error</title>
            </head>
            <body>
                <h1>Internal Server Error</h1>
                <p>\(description)</p>
            </body>
        </html>
        """)

    }
}
