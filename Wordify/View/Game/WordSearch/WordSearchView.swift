//
//  WordSearchView.swift
//  Wordify
//
//  Created by Alex Barbulescu on 2019-05-13.
//  Copyright © 2019 ca.alexs. All rights reserved.
//

import UIKit
import AVFoundation

///Protocol to let delegate know about the changes in words
protocol WordSearchViewDelegate: AnyObject {
    ///Let delegate know a knew word has been found
    func foundWord(word: Word)
    ///Let delegate know about new words
    func updateWords(words: [Word])
}

class WordSearchView: UIView, UIGestureRecognizerDelegate {
    //MARK: Vars
    
    ///size of grid
    private var size : Int = 0
    
    ///previous position of last valid highlighted char
    private var previousPos : Position?
    
    ///direction of current highlight
    private var direction : Direction?
    
    ///array of all child char cells
    private var cellArray = [CharCell]()
    
    ///previous detected cell as seen by pan gesture recognizer
    ///- Note: This is not necessarily the last highlighted char in the current highlight session, to check last highlighted check previousPos
    private var prevCell : CharCell?
    
    ///The highlighted, valid, char cells in order of selection
    private var highlightedCells = [CharCell]()
    
    ///SelectionFeedback generator for highlighting cells
    private var selectionFeedBack = UISelectionFeedbackGenerator()
    
    ///Player for popping sound effect
    private var player = AVAudioPlayer()
    
    ///Reference to all the words in the grid
    private var words = [Word](){
        didSet{
            //let delegate know about new words
            delegate?.updateWords(words: words)
        }
    }
    
    ///Delegate to implement WordSearchViewDelegate protocol
    weak var delegate : WordSearchViewDelegate?
    
    //MARK: View Components
    
    ///Parent container for all rows
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
        setupPlayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Setup
    
    //Sets up view
    private func setup(){
        //properties
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.offWhite
        layer.cornerRadius = 10
        
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
        
        selectionFeedBack.prepare()
    }
    
    ///Instantiates and prepares player for found word sound
    private func setupPlayer(){
        guard let url = Bundle.main.url(forResource: "selection", withExtension: "mp3") else {return}
        do {
            player = try AVAudioPlayer(contentsOf: url)
        } catch {
            print(error)
        }
        player.prepareToPlay()
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
                charView.matrixPos = Point(x: i, y: j)
                cellArray.append(charView)
                horCharStack.addArrangedSubview(charView)
            }
        }
        ///populate the cell arays, returns words
        words = Grid().populateGrid(sideLength: size, wordSet: Data.words, cellArray: cellArray)
    }
    
    ///deletes all chars and view componenets of grid, not used
    public func deleteChars(){
        for cell in self.cellArray {
            cell.removeFromSuperview()
        }

        for substack in stackContainer.subviews {
            substack.removeFromSuperview()
        }
        
        cellArray.removeAll()
        highlightedCells.removeAll()
    }
    
    ///reloads the word search
    public func reloadChars(){
        for cell in self.cellArray {
            cell.char = nil
        }
        words = Grid().populateGrid(sideLength: size, wordSet: Data.words, cellArray: cellArray)
    }


    ///Pan gesture detector, will handle the highlighting of cells
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
                //figure out the direction
                calculateDirection(sender)
                //highlight first cell
                _ = updateHighlightForCell(cell)
            case .changed:
                if cell != prevCell { //don't waste updateHighlight's time if its the same cell
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
    private func calculateDirection(_ sender: UIPanGestureRecognizer){
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
    private func checkForWord(){
        let charArray = highlightedCells.map({$0.char!})
        let candidateWord = String(charArray)
        let reversedCandidateWord = String(candidateWord.reversed())
        
        var found = false
        
        for (i,word) in words.enumerated() {
            if ( word.string == candidateWord || word.string == reversedCandidateWord ) && !word.found {
                found = true
                words[i].found = true
                player.play()
                delegate?.foundWord(word: word)
            }
        }
        
        if !found {
            for cell in highlightedCells {
                cell.removeHighlight()
            }
        }
        
        //reset everything
        prevCell = nil
        highlightedCells = []
        previousPos = nil
    }
    
    /**Gets called from the pan gesture recognizer if a new cell was selected, this function
    simply validates if the direction and sequence is correct. If the candidate cell is correct
    its state will be changed to highlighted*/
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
                    if cell.matrixPos.x != previousPos.matrixPos.x{
                        return //not in same direction
                    } else { //same direction, check if skipped
                        let diffY = abs(previousPos.matrixPos.y - cell.matrixPos.y)
                        if diffY > 1 {
                            return
                        }
                        
                    }
                case .horizontal:
                    if cell.matrixPos.y != previousPos.matrixPos.y{
                        return//not in same direction
                    } else { //same direction, check if skipped
                        let diffX = abs(previousPos.matrixPos.x - cell.matrixPos.x)
                        if diffX > 1 {
                            return
                        }
                    }
                default : //diagonal
                    if (cell.matrixPos.x == previousPos.matrixPos.x
                        || cell.matrixPos.y == previousPos.matrixPos.y) {
                        return //not diagonal
                    } else { //diagonal, check if right diagonal
                        let diffX = previousPos.matrixPos.x - cell.matrixPos.x
                        let diffY = previousPos.matrixPos.y - cell.matrixPos.y
                        
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
        selectionFeedBack.selectionChanged()
        return
    }
    
}
