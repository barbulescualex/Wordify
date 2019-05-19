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

///represents a word, with reference to the char cells
public struct Word : Equatable {
    var string : String
    var cells : [CharCell]
    var found = false
}
