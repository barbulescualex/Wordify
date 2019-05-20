//
//  Structs.swift
//  Wordify
//
//  Created by Alex Barbulescu on 2019-05-14.
//  Copyright © 2019 ca.alexs. All rights reserved.
//

import Foundation

///Specifies the positon of an object inside a matrix and the direction it was highlighted in
public struct Position {
    var direction : Direction?
    var matrixPos : (Int,Int)
}

public struct Rstring : Equatable {
    var value : String
    var reversed : Bool
    
    public func nonReversedValue() -> String {
        if reversed {
            return String(value.reversed())
        }
        return value
    }
}

public struct Point: Hashable {
    var x: Int
    var y: Int
}
