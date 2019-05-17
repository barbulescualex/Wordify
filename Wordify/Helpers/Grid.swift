//
//  Algorthims.swift
//  Wordify
//
//  Created by Alex Barbulescu on 2019-05-14.
//  Copyright © 2019 ca.alexs. All rights reserved.
//

import UIKit

class Grid{
    private var wordsIn = 0
    private var cellArray = [CharCell]()
    private var sideLength = 0
    private var words = [Word]()
    
    public func populateGrid(sideLength: Int, wordSet: [String], cellArray: [CharCell]) -> [Word]{
        self.sideLength = sideLength
        self.cellArray = cellArray
        
        addWord(string: wordSet[0])
        fillRest()
        return words
    }
    
    private func addWord(string: String){
        let charArray = string.map({$0})
        let size = charArray.count
        if wordsIn == 0 { //first word
            var word = Word(string: string, cells: [], found: false)
            if size < sideLength {
                for i in 0..<size {
                    cellArray[i].char = charArray[i]
                    word.cells.append(cellArray[i])
                }
            }
            words.append(word)
        }
    }
    
    private func fillRest(){
        for cell in cellArray {
            if cell.char == nil {
                cell.char = Data.randomChar
            }
        }
    }
    
}
