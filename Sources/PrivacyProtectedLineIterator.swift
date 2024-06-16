//
//  PrivacyProtectedLineIterator.swift
//
//  
//  Created by Tomohiro Kumagai on 2024/06/16
//  
//

struct PrivacyProtectedLineIterator : IteratorProtocol {
    
    
    private(set) var privacyProtectedLines: [Contents.Line]
    
    init(lines: some Sequence<Contents.Line>) throws {
        privacyProtectedLines = try lines.compactMap(Self.privacyProtected(_:))
    }
    
    mutating func next() -> Contents.Line? {
        
        guard !privacyProtectedLines.isEmpty else {
            return nil
        }
        
        return privacyProtectedLines.removeFirst()
    }
}

private extension PrivacyProtectedLineIterator {
        
    static let keepingNames = [
        "BEGIN",
        "CLASS",
        "CREATED",
        "DTEND",
        "DTSTAMP",
        "DTSTART",
        "END",
        "EXDATE",
        "LAST-MODIFIED",
        "PRIORITY",
        "RDATE",
        "RECURRENCE-ID",
        "RELATED-TO",
        "RRULE",
        "SEQUENCE",
        "STATUS",
        "TRANSP",
        "TZID",
        "TZNAME",
        "TZOFFSETFROM",
        "TZOFFSETTO",
        "UID",
        "VERSION",
        "X-APPLE-CALENDAR-COLOR",
        "X-FUNAMBOL-ALLDAY",
        "X-LIC-ERROR",
        "X-LIC-LOCATION",
    ]
    
    static let ignoringNames = [
        "",
        "APPLE-REFERENCEFRAME",
        "ATTACH",
        "ATTENDEE",
        "CONFERENCE",
        "GEO",
        "LOCATION",
        "ORGANIZER",
        "PARTSTAT",
        "URL",
    ]
    
    static let ignoringNamePatterns = [
        #/^[\d\-]+$/#,
    ]
    
    static let ignoringNamePrefixes = [
        "X-APPLE-",
        "X-MICROSOFT-",
    ]
    
    static let ignoringParameterPatterns: [Regex<Substring>] = [
        #/X-APPLE-MAPKIT-HANDLE/#
    ]
    
    static let ignoringScope = [
        "VALARM",
    ]

    static func privacyProtected(_ line: Contents.Line) throws -> Contents.Line? {
        
        if let scope = line.scope, ignoringScope.contains(scope) {
            return nil
        }
                
        switch line {
        
        case keepingNames.contains:
            return line

        case ignoringNames.contains:
            return nil
            
        case ignoringNamePatterns:
            return nil
            
        case "PRODID":
            return line.replacingValue(with: "-//privacy-protected-calendar.ez-net.jp//EN")
            
        case "X-WR-CALNAME":
            return line.replacingValue(with: "予定")
            
        case
            "DESCRIPTION",
            "SUMMARY":
            return line.replacingValue(with: "予定あり")
            
        case "CATEGORIES":
            return line.replacingValue(with: "所用")
            
        default:

            for prefix in ignoringNamePrefixes where line.name.hasPrefix(prefix) {
                return nil
            }
            
            for pattern in ignoringParameterPatterns where try pattern.firstMatch(in: line.parameter.rawValue) != nil {
                return nil
            }

            throw ContentsError("Unexpected item: \(line.name) (Scope: \(line.scope ?? ""))")
        }
    }
}
