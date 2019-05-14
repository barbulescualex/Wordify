//
//  WordSearchView.swift
//  Wordify
//
//  Created by Alex Barbulescu on 2019-05-13.
//  Copyright © 2019 ca.alexs. All rights reserved.
//

import UIKit

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
        Grid().populateGrid(sideLength: size, wordSet: Data.words, cellArray: cellArray)
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
            cell.char = Data.randomChar
        }
    }


    ///Pan gesture detector
    @objc func panned(_ sender: UIPanGestureRecognizer){
        let loc = sender.location(in: self)

        guard let cell = self.hitTest(loc, with: nil) as? CharCell else {
            //check if out of bounds
            if (loc.y < 0 || loc.y > self.bounds.height || loc.x < 0 || loc.x > self.bounds.width) {
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
            //might be diagonal
            let diffFactor = abs(v.x)/abs(v.y)
            if (diffFactor > 0.5 && diffFactor < 1.5){
                direction = .diagonal
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
        print(candidateWord)
        
        if Data.words.contains(candidateWord){
            for cell in highlightedCells {
                cell.solidify()
            }
        } else {
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
                case .diagonal:
                    if (cell.matrixPos.0 == previousPos.matrixPos.0
                        || cell.matrixPos.1 == previousPos.matrixPos.1) {
                        return //not in same direction
                    } else { //same direction, check if skipped
                        let diffX = previousPos.matrixPos.0 - cell.matrixPos.0
                        let diffY = previousPos.matrixPos.1 - cell.matrixPos.1
                        
                        if diffX != diffY {
                            return
                        } else {
                            if diffX > 1 {
                                return
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