//
//  CSwiftV.swift
//  CSwiftV
//
//  Created by Daniel Haight on 30/08/2014.
//  Copyright (c) 2014 ManyThings. All rights reserved.
//

import Foundation

//TODO: make these prettier and probably not extensions
public extension String {
    func splitOnNewLine () -> ([String]) {
        return self.components(separatedBy: CharacterSet.newlines)
    }
}

//MARK: Parser
open class CSwiftV {
    
    open let columnCount: Int
    open let headers: [String]
    open let keyedRows: [[String: String]]?
    open let rows: [[String]]
    
    public init(String string: String, headers: [String]?, separator: String) {
        
        let lines: [String] = includeQuotedStringInFields(Fields: string.splitOnNewLine().filter{(includeElement: String) -> Bool in
            return !includeElement.isEmpty
            }, quotedString: "\r\n")
        
        var parsedLines = lines.map{
            (transform: String) -> [String] in
            let commaSanitized = includeQuotedStringInFields(Fields: transform.components(separatedBy: separator),quotedString: separator)
                .map
                {
                    (input: String) -> String in
                    return sanitizedStringMap(String: input)
                }
                .map
                {
                    (input: String) -> String in
                    return input.replacingOccurrences(of: "\"\"", with: "\"", options: NSString.CompareOptions.literal)
            }
            
            return commaSanitized
        }
        
        let tempHeaders: [String]
        
        if let unwrappedHeaders = headers {
            tempHeaders = unwrappedHeaders
        }
        else {
            tempHeaders = parsedLines[0]
            parsedLines.remove(at: 0)
        }
        
        self.rows = parsedLines
        self.columnCount = tempHeaders.count
        
        let keysAndRows = self.rows.map { (field: [String]) -> [String: String] in
            
            var row = [String: String]()
            
            for (index, value) in field.enumerated() {
                row[tempHeaders[index]] = value
            }
            
            return row
        }
        
        self.keyedRows = keysAndRows
        self.headers = tempHeaders
    }
    
    //TODO: Document that this assumes header string
    public convenience init(String string: String) {
        self.init(String: string, headers: nil, separator: ",")
    }
    
    public convenience init(String string: String, separator: String) {
        self.init(String: string, headers: nil, separator: separator)
    }
    
    public convenience init(String string: String, headers: [String]?) {
        self.init(String: string, headers: headers, separator: ",")
    }
    
}

//MARK: Helpers
func includeQuotedStringInFields(Fields fields: [String], quotedString: String) -> [String] {
    
    var mergedField = ""
    var newArray = [String]()
    
    for field in fields {
        mergedField += field
        if mergedField.components(separatedBy: "\"").count%2 != 1 {
            mergedField += quotedString
            continue
        }
        newArray.append(mergedField)
        mergedField = ""
    }
    
    return newArray
}

func sanitizedStringMap(String string: String) -> String {
    
    let startsWithQuote = string.hasPrefix("\"")
    let endsWithQuote = string.hasSuffix("\"")
    
    if startsWithQuote && endsWithQuote {
        let startIndex = string.characters.index(string.startIndex, offsetBy: 1)
        let endIndex = string.characters.index(string.endIndex, offsetBy: -1)
        let range = startIndex ..< endIndex
        let sanitizedField = string.substring(with: range)
        
        return sanitizedField
    }
    else {
        return string
    }
    
}
