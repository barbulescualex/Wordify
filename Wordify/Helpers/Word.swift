//
//  Word.swift
//  Wordify
//
//  Created by Alex Barbulescu on 2019-05-19.
//  Copyright © 2019 ca.alexs. All rights reserved.
//

import Foundation

///represents a word, with reference to the char cells
public class Word : Equatable {
    public static func == (lhs: Word, rhs: Word) -> Bool {
        return lhs.string == rhs.string && lhs.cells == rhs.cells && lhs.found == rhs.found
    }
    
    public var string : String
    public var cells : [CharCell]
    public var found = false {
        didSet{
            if found {
                solidify()
            }
        }
    }
    
    init(string: String, cells: [CharCell]){
        self.string = string
        self.cells = cells
    }
    
    private func solidify(){
        for cell in cells {
            cell.solidify()
        }
    }
    
    public func show(){
        for cell in cells {
            cell.show()
        }
    }
}
