//
//  Enums.swift
//  Wordify
//
//  Created by Alex Barbulescu on 2019-05-14.
//  Copyright © 2019 ca.alexs. All rights reserved.
//

import Foundation

///Specifies direction a highlight should occur in
public enum Direction {
    case horizontal
    case vertical
//    case diagonal
    case diagonal_TL_BR //inbetween top left and bottom right
    case diagonal_TR_BL //inbetween top right and bottom left
}
