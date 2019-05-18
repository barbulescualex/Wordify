//
//  Algorthims.swift
//  Wordify
//
//  Created by Alex Barbulescu on 2019-05-14.
//  Copyright © 2019 ca.alexs. All rights reserved.
//

import UIKit

class Grid{
    //MARK: Vars
    private var wordsIn = 0
    private var cellArray = [CharCell]()
    private var sideLength = 0
    private var words = [Word]()
    private var wordsNotAdded = [String]()
    private var wordSet = [String]()
    
    //MARK: Entrance
    public func populateGrid(sideLength: Int, wordSet: [String], cellArray: [CharCell]) -> [Word]{
        self.sideLength = sideLength
        self.cellArray = cellArray
        self.wordSet = wordSet
        
        randomizeArray(&self.wordSet)
        
        addWords()
        addNotAdded()
        fillRest()
        return words
    }
    
    //MARK: Adding Words
    private func addWords(){
        for word in wordSet {
            _ = addWord(string: word, direction: nil)
        }
    }
    
    private func addNotAdded(){
        for word in wordsNotAdded {
            if(addWord(string: word, direction: .horizontal)) {
                continue
            }
            if(addWord(string: word, direction: .vertical)) {
                continue
            }
            if(addWord(string: word, direction: .diagonal_TL_BR)) {
                continue
            }
            if(addWord(string: word, direction: .diagonal_TR_BL)) {
                continue
            }
        }
    }
    
    private func addWord(string: String, direction: Direction?) -> Bool{
        //random direction to place the word in
        let dir = (direction == nil) ? Direction(rawValue: Int.random(in: 0...3)) ?? .horizontal : direction!
        let sizeOfWord = string.count
        
        //constraints and parameters for how we'll try to place the word
        var minX = 0
        var minY = 0
        
        var maxX = 0
        var maxY = 0
        
        var maxLoops = 0
        var indexIncrementer = 0
        
        switch dir {
            case .horizontal:
                minX = 0
                minY = 0
                maxX = sideLength - sizeOfWord
                maxY = sideLength - 1
                maxLoops = (maxY+1)*(maxX+1)
                indexIncrementer = 1
            case .vertical:
                minX = 0
                minY = 0
                maxX = sideLength - 1
                maxY = sideLength - sizeOfWord
                maxLoops = (maxY+1)*(maxX+1)
                indexIncrementer = sideLength
            case .diagonal_TL_BR:
                let startingCornerPoint = sideLength - sizeOfWord //will make square with the origin point of possible starting positions
                minY = 0
                minX = 0
                maxX = startingCornerPoint
                maxY = startingCornerPoint
                maxLoops = (maxY+1)*(maxX+1)
                indexIncrementer = sideLength + 1
            case .diagonal_TR_BL:
                let startingCornerPoint = sideLength - sizeOfWord //will make square with the origin point of possible starting positions
                minY = 0
                maxX = sideLength - 1
                minX = sideLength - 1 - startingCornerPoint
                maxY = startingCornerPoint
                maxLoops = (maxY+1)*(sideLength-minX)
                indexIncrementer = sideLength - 1
        }
        
        return tryToPlaceWord(minX: minX, minY: minY, maxX: maxX, maxY: maxY, maximumLoops: maxLoops, indexIncrementor: indexIncrementer, string: string)
    }
    
    private func tryToPlaceWord(minX: Int, minY: Int, maxX: Int, maxY: Int, maximumLoops: Int, indexIncrementor: Int, string: String) -> Bool{
        let charArray = string.map({$0})
        
        var placed = false
        
        var maxLoops = maximumLoops
        
        var charCells = [CharCell]()
        
        while(!placed && maxLoops != 0){
            maxLoops -= 1
            let candidateX = Int.random(in: minX...maxX)
            let candidateY = Int.random(in: minY...maxY)
            
            var indexInCellArray = candidateY*sideLength + candidateX
            var couldPlace = true
            
            for char in charArray {
                let cell = cellArray[indexInCellArray]
                if (cell.char == nil) {
                    cell.char = char //add the word char in
                    charCells.append(cell) //add it to the charCells
                    indexInCellArray += indexIncrementor
                    continue
                }
                if (cell.char == char){
                    charCells.append(cell) //we're good with the overlap
                    indexInCellArray += indexIncrementor
                    continue
                }
                //else conflict, try new candidate placement
                for cell in charCells { //clear assignments
                    cell.char =  nil
                }
                charCells.removeAll()
                couldPlace = false
                break
            }
            
            if couldPlace {
                //everything was placed sucessfully
                placed = true
                let word = Word(string: string, cells: charCells, found: false)
                words.append(word)
                
                if let index = wordsNotAdded.firstIndex(of: string) {
                    wordsNotAdded.remove(at: index)
                }
            } //else loop again with new random position
        }
        if !placed {
            wordsNotAdded.append(string)
        }
        return placed
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
    
    private func clearAll(){
        for cell in cellArray {
            cell.char = nil
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
