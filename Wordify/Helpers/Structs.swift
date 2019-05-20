//
//  Structs.swift
//  Wordify
//
//  Created by Alex Barbulescu on 2019-05-14.
//  Copyright © 2019 ca.alexs. All rights reserved.
//

import Foundation

///Specifies the positon of an object inside a matrix and the direction it was highlighted in
struct Position {
    ///Direction the position is in
    var direction : Direction?
    ///The matrix position
    var matrixPos : Point
}

///String with information on the direction of the string value
struct Rstring : Equatable {
    ///Value of string (not gauranteed to be in forward direction)
    var value : String
    
    ///Flag to check if the string is reversed or not
    var reversed : Bool
    
    ///Returns string in proper direction
    public func nonReversedValue() -> String {
        if reversed {
            return String(value.reversed())
        }
        return value
    }
}

///Point in a matrix
//Why I chose not to use a CGPoint: https://codereview.stackexchange.com/questions/148763/extending-cgpoint-to-conform-to-hashable
struct Point: Hashable {
    var x: Int
    var y: Int
}
