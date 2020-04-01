//
//  Post.swift
//  NoMoPromoClassifier
//
//  Created by Jacob Clayden on 23/03/2020.
//  Copyright © 2020 Jacob Clayden. All rights reserved.
//

import AppKit

class Post: Equatable {
    let identifier: String
    let text: String
    var imageURLs = [URL]()
    var isAd: Bool? {
        get {
            classifiedDict[identifier]
        }
        set {
            classifiedDict[identifier] = newValue
        }
    }

    private var classifiedDict: [String: Bool] {
        get {
            guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else {
                return [String: Bool]()
            }
            return appDelegate.classifiedDict
        }
        set {
            if let appDelegate = NSApplication.shared.delegate as? AppDelegate {
                appDelegate.classifiedDict = newValue
            }
        }
    }

    init(identifier: String, text: String) {
        self.identifier = identifier
        self.text = text
    }

    static func == (lhs: Post, rhs: Post) -> Bool {
        lhs.identifier == rhs.identifier
    }

    static let null = Post(identifier: "", text: "")
}
