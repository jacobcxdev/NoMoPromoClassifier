//
//  RuntimeError.swift
//  NoMoPromoClassifier
//
//  Created by Jacob Clayden on 23/03/2020.
//  Copyright © 2020 Jacob Clayden. All rights reserved.
//

import Foundation

struct RuntimeError: LocalizedError {
    var title: String
    private var _description: String

    var errorDescription: String? {
        "\(title): \(_description)"
    }
    var failureReason: String? {
        _description
    }

    init(title: String = "Error", description: String) {
        self.title = title
        self._description = description
    }

    init(sender: Any, description: String) {
        self.title = "\(String(describing: type(of: sender))) Error"
        self._description = description
    }
}
