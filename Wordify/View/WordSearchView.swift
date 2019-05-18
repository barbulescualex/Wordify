//
//  WordSearchView.swift
//  Wordify
//
//  Created by Alex Barbulescu on 2019-05-13.
//  Copyright © 2019 ca.alexs. All rights reserved.
//

import UIKit

protocol WordSearchViewDelegate: AnyObject {
    func foundWord(word: Word)
}

class WordSearchView: UIView, UIGestureRecognizerDelegate {
    //MARK: Vars
    ///size of grid
    var size : Int = 0
    
    ///previous position of last valid highlighted char
    var previousPos : Position?
    
    ///direction of current highlight
    var direction : Direction?
    
    ///array of all child char cells
    var cellArray = [CharCell]()
    
    ///previous detected cell as seen by pan gesture recognizer
    ///- Note: This is not necessarily the last highlighted char in the current highlight session, to check last highlighted check previousPos
    var prevCell : CharCell?
    
    ///The highlighted, valid, char cells in order of selection
    var highlightedCells = [CharCell]()
    
    ///Reference to all the words in the grid
    var words = [Word]()
    
    weak var delegate : WordSearchViewDelegate?
    
    //MARK: View Components
    private var stackContainer : UIStackView = {
        let stackContainer = UIStackView()
        stackContainer.axis = .vertical
        stackContainer.distribution = .fillEqually
        stackContainer.translatesAutoresizingMaskIntoConstraints = false
        return stackContainer
    }()
    
    //MARK: Init
    required init(size: Int){
        self.size = size
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Setup
    fileprivate func setup(){
        //properties
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.offWhite
        
        //shadow
        layer.masksToBounds = false
        layer.cornerRadius = 10
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = 5
        
        //children
        addSubview(stackContainer)
        NSLayoutConstraint.activate([
            stackContainer.topAnchor.constraint(equalTo: topAnchor,constant: 2),
            stackContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
            stackContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
            stackContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2)
        ])
        
        //pan gesture detector
        let panRecgonizer = UIPanGestureRecognizer(target: self, action: #selector(panned(_:)))
        panRecgonizer.delegate = self
        panRecgonizer.maximumNumberOfTouches = 1
        addGestureRecognizer(panRecgonizer)
    }
    
    //MARK: Char Operations
    
    ///populates chars and sets up grid
    ///- Warning: Call only once, does not delete current grid view components
    public func populateChars(){
        var i = -1
        var j = -1
        for _ in 0..<size {
            j = j + 1
            let horCharStack = UIStackView()
            horCharStack.axis = .horizontal
            horCharStack.distribution = .fillEqually
            horCharStack.alignment = .center
            
            stackContainer.addArrangedSubview(horCharStack)
            i = -1
            for _ in 0..<size{
                i = i + 1
                let charView = CharCell(char: nil)
                charView.matrixPos = (i,j)
                cellArray.append(charView)
                horCharStack.addArrangedSubview(charView)
            }
        }
        words = Grid().populateGrid(sideLength: size, wordSet: Data.words, cellArray: cellArray)
    }
    
    ///deletes all chars and view componenets of grid
    public func deleteChars(){
        for cell in self.cellArray {
            cell.removeFromSuperview()
        }

        for substack in stackContainer.subviews {
            substack.removeFromSuperview()
        }
        
        cellArray = []
        highlightedCells = []
    }
    
    ///reloads the word search
    public func reloadChars(){
        for cell in self.cellArray {
            cell.char = nil
        }
        words = Grid().populateGrid(sideLength: size, wordSet: Data.words, cellArray: cellArray)
    }


    ///Pan gesture detector
    @objc func panned(_ sender: UIPanGestureRecognizer){
        let loc = sender.location(in: self)

        guard let cell = self.hitTest(loc, with: nil) as? CharCell else {
            //check if out of bounds
            if (loc.y < 0 || loc.y > self.bounds.height || loc.x < 5 || loc.x > self.bounds.width - 5) {
                checkForWord()
                sender.cancel()
            }
            return
        }
        
        switch sender.state {
            case .began:
                calculateDirection(sender)
                _ = updateHighlightForCell(cell)
            case .changed:
                if cell != prevCell {
                    updateHighlightForCell(cell)
                }
            case .ended:
                checkForWord()
            case .cancelled:
                checkForWord()
            default:
                print("defualted in pan recognizer for WordSearchView")
        }
        
        prevCell = cell
    }
    
    ///Estimates direction that the highlight is in, updates direction property
    fileprivate func calculateDirection(_ sender: UIPanGestureRecognizer){
        let v = sender.velocity(in: self)
        
        //check diagonal
        if (abs(v.x) != 0 && abs(v.y) != 0){
            let diffFactor = abs(v.x)/abs(v.y)
            if (diffFactor > 0.5 && diffFactor < 1.5){ //might be diagonal
                if (v.y < 0 && v.x < 0) || (v.y > 0 && v.x > 0) {
                    direction = .diagonal_TL_BR //velocity is from top left to bottom right or vice versa
                } else { //opposing x and y direction
                    direction = .diagonal_TR_BL // velocity is from top right to bottom left or vice versa
                }
                return
            }
        }
        
        if (abs(v.x) > abs(v.y)){
            direction = .horizontal
        } else {
            direction = .vertical
        }
    }
    
    ///Checks the highlightedChars array to see if it forms a valid word
    fileprivate func checkForWord(){
        let charArray = highlightedCells.map({$0.char!})
        let candidateWord = String(charArray)
        let reversedCandidateWord = String(candidateWord.reversed())
        
        var found = false
        
        for (i,word) in words.enumerated() {
            if ( word.string == candidateWord || word.string == reversedCandidateWord ) && !word.found {
                found = true
                words[i].found = true
                print(word)
//                print("Found word: ", word.string)
                for cell in word.cells {
                    cell.solidify()
                }
                delegate?.foundWord(word: word)
            }
        }
        
        if !found {
            for cell in highlightedCells {
                cell.removeHighlight()
            }
        }
        
        prevCell = nil
        highlightedCells = []
        previousPos = nil
    }
    
    ///Resets the current highlight false
    fileprivate func cancelHighlight(){
        for cell in highlightedCells {
            cell.removeHighlight()
        }
        highlightedCells = []
        prevCell = nil
        previousPos = nil
    }
    
    
    public func showWord(named: String){
        for word in words {
            if word.string == named {
                for cell in word.cells {
                    cell.show()
                }
            }
        }
    }
    
    ///Gets called from the pan gesture recognizer if a new cell was selected, this function
    ///simply validates if the direction and sequence is correct. If the candidate cell is correct
    ///its state will be changed to highlighted
    fileprivate func updateHighlightForCell(_ cell: CharCell){
        //checking for overlap
        if highlightedCells.contains(cell){
            return
        }
        
        var positionUpdated = false
        
        if let previousPos = previousPos { //not the starting cell

            if let direction = previousPos.direction {
                //check for valid direction, if no valid direction return
                switch direction {
                case .vertical:
                    if cell.matrixPos.0 != previousPos.matrixPos.0{
                        return //not in same direction
                    } else { //same direction, check if skipped
                        let diffY = abs(previousPos.matrixPos.1 - cell.matrixPos.1)
                        if diffY > 1 {
                            return
                        }
                        
                    }
                case .horizontal:
                    if cell.matrixPos.1 != previousPos.matrixPos.1{
                        return//not in same direction
                    } else { //same direction, check if skipped
                        let diffX = abs(previousPos.matrixPos.0 - cell.matrixPos.0)
                        if diffX > 1 {
                            return
                        }
                    }
                default : //diagonal
                    if (cell.matrixPos.0 == previousPos.matrixPos.0
                        || cell.matrixPos.1 == previousPos.matrixPos.1) {
                        return //not diagonal
                    } else { //diagonal, check if right diagonal
                        let diffX = previousPos.matrixPos.0 - cell.matrixPos.0
                        let diffY = previousPos.matrixPos.1 - cell.matrixPos.1
                        
                        if direction == .diagonal_TL_BR {
                            if (diffX != diffY){
                                return //wrong axis
                            }
                            if (abs(diffX) > 1){
                                return //went ahead
                            }
                        } else { //direction == .diagonal_TR_BL
                            if (abs(diffX) != abs(diffY)) || !(diffX < diffY || diffY < diffX){
                                return //wrong axis
                            }
                            
                            if abs(diffX) > 1{
                                return //went ahead
                            }
                        }
                    }
                }
            }
        } else { //starting cell
            previousPos = Position(direction: direction, matrixPos: cell.matrixPos)
            positionUpdated = true
        }
        
        if !positionUpdated {
            let newPosition = Position(direction: previousPos?.direction, matrixPos: cell.matrixPos)
            previousPos = newPosition
        }

        highlightedCells.append(cell)
        cell.addHighlight()
        return
    }
    
}
