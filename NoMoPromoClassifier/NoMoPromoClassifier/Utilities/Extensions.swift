//
//  Extensions.swift
//  NoMoPromoClassifier
//
//  Created by Jacob Clayden on 23/03/2020.
//  Copyright © 2020 Jacob Clayden. All rights reserved.
//

import Foundation

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension String {
    static let kLastUsedPathKey = "lastUsedPath"
    static let kClassifiedDictKey = "classifiedDict"
    
    var condensedWhitespace: String {
        let components = self.components(separatedBy: NSCharacterSet.whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func asciiString() -> String {
        String(filter(\.isASCII))
    }
}
