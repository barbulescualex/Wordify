//
//  WordSearchView.swift
//  Wordify
//
//  Created by Alex Barbulescu on 2019-05-13.
//  Copyright © 2019 ca.alexs. All rights reserved.
//

import UIKit


public enum Direction {
    case horizontal
    case vertical
    case diagonal
}

struct Position {
    var direction : Direction?
    var matrixPos : (Int,Int)
}

class WordSearchView: UIView {
    var size : Int = 0
    
    var previousPos : Position? {
        didSet{
            print(previousPos)
        }
    }
    
    private var stackContainer : UIStackView = {
        let stackContainer = UIStackView()
        stackContainer.axis = .vertical
        stackContainer.distribution = .fillEqually
        stackContainer.translatesAutoresizingMaskIntoConstraints = false
        return stackContainer
    }()
    
    required init(size: Int){
        self.size = size
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setup(){
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.offWhite
        
        //shadow
        layer.masksToBounds = false
        layer.cornerRadius = 10
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = 5
        
        addSubview(stackContainer)
        NSLayoutConstraint.activate([
            stackContainer.topAnchor.constraint(equalTo: topAnchor,constant: 2),
            stackContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
            stackContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
            stackContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2)
        ])
        
        let panRecgonizer = UIPanGestureRecognizer(target: self, action: #selector(panned(_:)))
        panRecgonizer.delegate = self
        panRecgonizer.maximumNumberOfTouches = 1
        addGestureRecognizer(panRecgonizer)
    }
    
    var cellArray = [CharView]()
    
   func populateChars(){
        print(size)
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
                let charView = CharView(char: Data.randomChars.randomElement()!)
                charView.matrixPos = (i,j)
                cellArray.append(charView)
                horCharStack.addArrangedSubview(charView)
            }
        }
    }
    
    func deleteChars(){
        for cell in self.cellArray {
            cell.removeFromSuperview()
        }

        for substack in stackContainer.subviews {
            substack.removeFromSuperview()
        }
        
        cellArray = []
        highlightedCells = []
    }
    
    func reloadChars(){
        for cell in self.cellArray {
            cell.char = Data.randomChars.randomElement()
        }
    }
    
    var prevCell : CharView?
    
    var highlightedCells = [CharView](){
        didSet{
//            let arr = highlightedCells.map({ $0.char! })
//            print(arr)
        }
    }
    
    @objc func panned(_ sender: UIPanGestureRecognizer){
        let loc = sender.location(in: self)

        guard let cell = self.hitTest(loc, with: nil) as? CharView else {
            //check if out of bounds
            if (loc.y < 0 || loc.y > self.bounds.height || loc.x < 0 || loc.x > self.bounds.width) {
                checkForWord()
                sender.cancel()
            }
            return
        }
        
        switch sender.state {
            case .began:
                _ = updateHighlightForCell(cell)
            case .changed:
                if cell != prevCell {
                    if !updateHighlightForCell(cell) {
                        sender.cancel()
                    }
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
    
    fileprivate func checkForWord(){
        for cell in highlightedCells {
            cell.removeHighlight()
        }
        prevCell = nil
        highlightedCells = []
        previousPos = nil
    }
    
    fileprivate func cancelHighlight(){
        for cell in highlightedCells {
            cell.removeHighlight()
        }
        highlightedCells = []
        previousPos = nil
    }
    
    fileprivate func updateHighlightForCell(_ cell: CharView) -> Bool{
        //checking for overlap
        if highlightedCells.contains(cell){
            cancelHighlight()
            return false
        }
        
        var positionUpdated = false
        
        if let previousPos = previousPos { //not the starting cell

            if let direction = previousPos.direction {
                print("previous direction exists: ", direction, " candidate cell positon: ", cell.matrixPos)
                //check for valid direction, if no valid direction return
                switch direction {
                case .vertical:
                    if cell.matrixPos.0 != previousPos.matrixPos.0{
                        return true //not in same direction
                    } else { //same direction, check if skipped
                        let diffY = abs(previousPos.matrixPos.1 - cell.matrixPos.1)
                        if diffY > 1 {
                            return true
                        }
                        
                    }
                case .horizontal:
                    if cell.matrixPos.1 != previousPos.matrixPos.1{
                        return true//not in same direction
                    } else { //same direction, check if skipped
                        let diffX = abs(previousPos.matrixPos.0 - cell.matrixPos.0)
                        if diffX > 1 {
                            return true
                        }
                    }
                case .diagonal:
                    if (cell.matrixPos.0 == previousPos.matrixPos.0
                        || cell.matrixPos.1 == previousPos.matrixPos.1) {
                        return true //not in same direction
                    } else { //same direction, check if skipped
                        let diffX = abs(previousPos.matrixPos.0 - cell.matrixPos.0)
                        let diffY = abs(previousPos.matrixPos.1 - cell.matrixPos.1)
                        
                        if diffX != diffY {
                            return false
                        } else {
                            if diffX > 1 {
                                return true
                            }
                        }
                    }
                }
            } else { //establish direction
                print("no direction exists, establishing direction")
                if cell.matrixPos.0 == previousPos.matrixPos.0 { //vertical
                     self.previousPos = Position(direction: .vertical, matrixPos: cell.matrixPos)
                } else if cell.matrixPos.1 == previousPos.matrixPos.1 { //horizontal
                    self.previousPos = Position(direction: .horizontal, matrixPos: cell.matrixPos)
                } else if ((abs(cell.matrixPos.0 - previousPos.matrixPos.0) == 1)&&(abs(cell.matrixPos.1 - previousPos.matrixPos.1) == 1)){ //horizontal
                    self.previousPos = Position(direction: .diagonal, matrixPos: cell.matrixPos)
                } else { //not valid direction, don't update the highlight
                    print("no valid direction")
                    return true
                }
                positionUpdated = true
            }
        } else { //starting cell
            print("starting cell")
            previousPos = Position(direction: nil, matrixPos: cell.matrixPos)
            positionUpdated = true
        }
        
        if !positionUpdated {
            let newPosition = Position(direction: previousPos?.direction, matrixPos: cell.matrixPos)
            print("previous position updated")
            previousPos = newPosition
        }

        highlightedCells.append(cell)
        cell.updateHighlight()
        return true
    }
    
}

extension WordSearchView : UIGestureRecognizerDelegate {
    
}
