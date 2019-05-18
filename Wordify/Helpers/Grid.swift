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
        
        addWords()
        fillRest()

        return words
    }
    
    private func addWords(){
        for word in self.wordSet {
            addWord(string: word)
        }
    }
    
    private func addWord(string: String){
        //random direction to place the word in
        let direction = Direction(rawValue: Int.random(in: 0...3)) ?? .horizontal
        let charArray = string.map({$0})
        let sizeOfWord = charArray.count
        
        if direction == .horizontal {
            //constraints on y axis
            let minX = 0
            let minY = 0
            
            //constraints on x axis
            var maxX = sideLength - sizeOfWord
            let maxY = sideLength - 1
            
            var maxLoops = (maxY+1)*(maxX+1)
            
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
        
        if direction == .vertical {
            let minX = 0
            let minY = 0
            
            let maxX = sideLength - 1
            var maxY = sideLength - sizeOfWord
            
            var maxLoops = (maxY+1)*(maxX+1)
            
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
                        indexInCellArray += sideLength
                        continue
                    }
                    if (cell.char == char){
                        charCells.append(cell) //we're good with the overlap
                        indexInCellArray += sideLength
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
        
        if direction == .diagonal_TL_BR {
            //shopify
            var startingCornerPoint = sideLength - sizeOfWord //will make square with the origin point of possible starting positions
            if startingCornerPoint < 0 {
                startingCornerPoint = 0
            }
            let minY = 0
            let minX = 0
            let maxX = startingCornerPoint
            let maxY = startingCornerPoint
            
            var maxLoops = (maxY+1)*(maxX+1)
            
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
                        indexInCellArray += sideLength + 1
                        continue
                    }
                    if (cell.char == char){
                        charCells.append(cell) //we're good with the overlap
                        indexInCellArray += sideLength + 1
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
        
        if direction == .diagonal_TR_BL {
            //shopify
            var startingCornerPoint = sideLength - sizeOfWord //will make square with the origin point of possible starting positions
            
            let minY = 0
            let maxX = sideLength - 1
            
            let minX = sideLength - 1 - startingCornerPoint
            let maxY = startingCornerPoint
            
            var maxLoops = (maxY+1)*(sideLength-minX)
            
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
                        indexInCellArray += sideLength - 1
                        continue
                    }
                    if (cell.char == char){
                        charCells.append(cell) //we're good with the overlap
                        indexInCellArray += sideLength - 1
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
