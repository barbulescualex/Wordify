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
    
    public func populateGrid(sideLength: Int, wordSet: [String], cellArray: [CharCell]){
        self.sideLength = sideLength
        self.cellArray = cellArray
        
        addWord(string: wordSet[0])
        fillRest()
    }
    
    private func addWord(string: String){
        let charArray = string.map({$0})
        let size = charArray.count
        if wordsIn == 0 { //first word
            if size < sideLength {
                for i in 0..<size {
                    cellArray[i].char = charArray[i]
                }
            }
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
