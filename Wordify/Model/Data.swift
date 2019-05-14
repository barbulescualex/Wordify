//
//  Data.swift
//  Wordify
//
//  Created by Alex Barbulescu on 2019-05-13.
//  Copyright © 2019 ca.alexs. All rights reserved.
//

import Foundation

class Data {
    static let words = [
        "swift",
        "kotlin",
        "objectivec",
        "variable",
        "java",
        "mobile",
        "shopify",
        "ios"
    ]
    
    static var randomChar : Character? {
        let randomChars = "abcdefghijklmnopqrstuvwxyz"
        return randomChars.randomElement()
    }
}
