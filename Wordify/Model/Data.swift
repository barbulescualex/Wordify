//
//  Data.swift
//  Wordify
//
//  Created by Alex Barbulescu on 2019-05-13.
//  Copyright © 2019 ca.alexs. All rights reserved.
//

import Foundation

///Data model for the application
class Data {
    ///Avaiable words for the word search view
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
    
    ///Returns random lower case character
    static var randomChar : Character? {
        let randomChars = "abcdefghijklmnopqrstuvwxyz"
        return randomChars.randomElement()
    }
}
