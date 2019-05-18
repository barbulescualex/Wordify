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
    private var wordSet = [String]()
    
    public func populateGrid(sideLength: Int, wordSet: [String], cellArray: [CharCell]) -> [Word]{
        self.sideLength = sideLength
        self.cellArray = cellArray
        self.wordSet = wordSet
        
        randomizeArray(&self.wordSet)
        
        addWordHelper()
        fillRest()

        return words
    }
    
    private func addWord(string: String){
        //random direction to place the word in
        let direction = Direction.horizontal
        let charArray = string.map({$0})
        let sizeOfWord = charArray.count
        
        var c = false
        if direction == .horizontal {
            let minY = 0
            let maxY = sideLength - 1
            
            let minX = 0
            var maxX = sideLength - sizeOfWord - 1
            var maxLoops = maxY*maxX
            
            if maxX < 0 {
                maxX = 0
            }
            if maxX == 0 {
                maxLoops = maxY
            }
            
            var placed = false
            
            
            var charCells = [CharCell]()
            
            while(!placed && maxLoops != 0){
                maxLoops -= 1
                let candidateX = Int.random(in: minX...maxX)
                let candidateY = Int.random(in: minY...maxY)
                
                var indexInCellArray = candidateY*sideLength + candidateX
                var couldPlace = true
                
                for (i,char) in charArray.enumerated() {
                    let cell = cellArray[indexInCellArray]
                    if (cell.char == nil) {
                        cell.char = char //add the word char in
                        charCells.append(cell) //add it to the charCells
                        indexInCellArray += 1
                        continue
                    }
                    if (cell.char == char){
                        charCells.append(cell) //we're good with the overlap
                        indexInCellArray += 1
                        continue
                    }
                    //else conflict, try new candidate placement
                    charCells = []//clear
                    couldPlace = false
                    break
                }
                
                if couldPlace {
                    //everything was placed sucessfully
                    placed = true
                    let word = Word(string: string, cells: charCells, found: false)
                    words.append(word)
                } //else loop again with new random position
            }
            
            if placed == false {
                print("couldn't place: ", string)
            }
        }
    }
    
    private func addWordHelper(){
        for word in self.wordSet {
            addWord(string: word)
        }
    }
    
    
    //MARK: Helpers
    
    ///Fill in all empty cells
    private func fillRest(){
        for cell in cellArray {
            if cell.char == nil {
                cell.char = Data.randomChar
            }
        }
    }
    
    ///Randomize order and direction of words passed in to populate grid
    private func randomizeArray(_ array: inout [String]){
        //randomize order
        array.shuffle()
        //randomize direction (forward backwards)
        array = array.map({ val -> String in
            let random = Bool.random()
            if random {
                return String(val.reversed())
            } else {
                return val
            }
        })
    }
    
}
