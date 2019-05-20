//
//  Enums.swift
//  Wordify
//
//  Created by Alex Barbulescu on 2019-05-14.
//  Copyright © 2019 ca.alexs. All rights reserved.
//

import Foundation

///Specifies direction in the WordSearchView
enum Direction : Int {
    case horizontal
    case vertical
    case diagonal_TL_BR //inbetween top left and bottom right
    case diagonal_TR_BL //inbetween top right and bottom left
}
