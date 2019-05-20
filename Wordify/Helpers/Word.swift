//
//  Word.swift
//  Wordify
//
//  Created by Alex Barbulescu on 2019-05-19.
//  Copyright © 2019 ca.alexs. All rights reserved.
//

import Foundation

///Represents a word, with reference to the char cells
class Word : Equatable {
    //MARK: Vars
    
    ///The string the word represents
    public var string : String
    
    ///The char cells that holds the word
    public var cells : [CharCell]
    
    ///Flag for if the word is found or not
    public var found = false {
        didSet{
            if found {
                solidify()
            }
        }
    }
    
    //MARK: Init
    init(string: String, cells: [CharCell]){
        self.string = string
        self.cells = cells
    }
    
    //MARK: Functions
    
    ///Soldifiess all cells that make up the word
    private func solidify(){
        for cell in cells {
            cell.solidify()
        }
    }
    
    ///Shows all cells that make up the word
    public func show(){
        for cell in cells {
            cell.show()
        }
    }
    
    public static func == (lhs: Word, rhs: Word) -> Bool {
        return lhs.string == rhs.string && lhs.cells == rhs.cells && lhs.found == rhs.found
    }
}
