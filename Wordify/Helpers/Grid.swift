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
    
    ///Reference to all the CharCells in the grid
    private var cellArray = [CharCell]()
    
    ///Sidelength of the grid
    private var sideLength = 0
    
    ///Strings to use to populate grid
    private var wordSet = [Rstring]()
    
    ///Words in grid
    private var words = [Word]()
    
    ///words not added in after a run of trying to place strings
    private var wordsNotAdded = [Rstring]()
    
    //MARK: Entrance
    public func populateGrid(sideLength: Int, wordSet: [String], cellArray: [CharCell]) -> [Word]{
        self.sideLength = sideLength
        self.cellArray = cellArray
        self.wordSet = wordSet.map({Rstring(value: $0, reversed: false)}) //convert strings to Rstrings
        
        //randomize order and direction
        randomizeArray(&self.wordSet)
        
        //keep trying to place words until all words are in
        while(words.count != wordSet.count){
            clearAll()
            addWords()
            addNotAdded()
        }
        //fill empty cells
        fillRest()
        
        return words
    }
    
    //MARK: Adding Words
    
    ///Will try and add in strings from the wordSet
    private func addWords(){
        for word in wordSet {
            _ = addWord(rstring: word, direction: nil)
        }
    }
    
    ///Will try and add in words in that failed from addWords() by manually trying each direction
    private func addNotAdded(){
        for word in wordsNotAdded {
            if(addWord(rstring: word, direction: .horizontal)) {
                continue
            }
            if(addWord(rstring: word, direction: .vertical)) {
                continue
            }
            if(addWord(rstring: word, direction: .diagonal_TL_BR)) {
                continue
            }
            if(addWord(rstring: word, direction: .diagonal_TR_BL)) {
                continue
            }
        }
    }
    
    ///Prepares constraints for adding a word based off of the direction and size
    private func addWord(rstring: Rstring, direction: Direction?) -> Bool{
        //random direction to place the word in
        let dir = (direction == nil) ? Direction(rawValue: Int.random(in: 0...3)) ?? .horizontal : direction!
        let sizeOfWord = rstring.value.count
        
        //constraints and parameters for how we'll try to place the word
        
        //these coordinates represent a rectangle of possible starting positions
        var minX = 0
        var minY = 0
        
        var maxX = 0
        var maxY = 0
        
        //the area of the rectangle (the number of possible starting positions)
        var maxLoops = 0
        
        //increment size for moving to the next char cell in the direction
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
                let startingCornerPoint = sideLength - sizeOfWord
                minY = 0
                minX = 0
                maxX = startingCornerPoint
                maxY = startingCornerPoint
                maxLoops = (maxY+1)*(maxX+1)
                indexIncrementer = sideLength + 1
            case .diagonal_TR_BL:
                let startingCornerPoint = sideLength - sizeOfWord
                minY = 0
                maxX = sideLength - 1
                minX = sideLength - 1 - startingCornerPoint
                maxY = startingCornerPoint
                maxLoops = (maxY+1)*(sideLength-minX)
                indexIncrementer = sideLength - 1
        }

        return tryToPlaceWord(minX: minX, minY: minY, maxX: maxX, maxY: maxY, maximumLoops: maxLoops, indexIncrementor: indexIncrementer, rstring: rstring)
    }
    
    ///Tries all positions within constraint to place the word, returns true if the word was placed in sucessfully
    private func tryToPlaceWord(minX: Int, minY: Int, maxX: Int, maxY: Int, maximumLoops: Int, indexIncrementor: Int, rstring: Rstring) -> Bool{
        var placed = false
        let charArray = rstring.value.map({$0})
        
        var maxLoops = maximumLoops
        
        //the cells that will hold the word if it could be placed
        var charCells = [CharCell]()
        
        //set of already visited points
        var memoize = Set<Point>()

        while(!placed && maxLoops != 0){
            maxLoops -= 1
            let candidateX = Int.random(in: minX...maxX)
            let candidateY = Int.random(in: minY...maxY)
            let point = Point(x: candidateX, y: candidateY)
            
            if memoize.contains(point){ //try again
                maxLoops+=1
                continue
            } else {
                memoize.insert(point)
            }
            
            var indexInCellArray = candidateY*sideLength + candidateX //starting cell
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
                    if !cell.isPartOfWord {
                        cell.char = nil
                    }
                }
                charCells.removeAll()
                couldPlace = false
                break
            }
            
            if couldPlace {
                //everything was placed sucessfully
                placed = true
                for cell in charCells {
                    cell.isPartOfWord = true
                }
                let word = Word(string: rstring.nonReversedValue(), cells: charCells)
                words.append(word)
                if let index = wordsNotAdded.firstIndex(of: rstring) {
                    wordsNotAdded.remove(at: index)
                }
            } //else loop again with new random position
        }
        if !placed {
            if !wordsNotAdded.contains(rstring) {
                wordsNotAdded.append(rstring)
            }
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
    
    ///Reset all cells
    private func clearAll(){
        for cell in cellArray {
            cell.char = nil
            cell.isPartOfWord = false
        }
        words.removeAll()
        wordsNotAdded.removeAll()
    }
    
    ///Randomize order and direction of words passed in to populate grid
    private func randomizeArray(_ array: inout [Rstring]){
        //randomize order
        array.shuffle()
        //randomize direction (forward backwards)
        array = array.map({ (rstring) -> (Rstring) in
            let reverse = Bool.random()
            if reverse {
                return (Rstring(value: String(rstring.value.reversed()), reversed: true))
            } else {
                return (Rstring(value: rstring.value, reversed: false))
            }
        })

    }
    
}
