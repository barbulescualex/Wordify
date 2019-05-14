//
//  WordSearchView.swift
//  Wordify
//
//  Created by Alex Barbulescu on 2019-05-13.
//  Copyright © 2019 ca.alexs. All rights reserved.
//

import UIKit

public enum WordTouchState {
    case none
    case listening
}

class WordSearchView: UIView {
    var size : Int = 0
    
    var touchState : WordTouchState = .none
    
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
        for _ in 0..<size {
            let horCharStack = UIStackView()
            horCharStack.axis = .horizontal
            horCharStack.distribution = .fillEqually
            horCharStack.alignment = .center
            
            stackContainer.addArrangedSubview(horCharStack)
            
            for _ in 0..<size{
                let charView = CharView(char: Data.randomChars.randomElement()!)
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
            let arr = highlightedCells.map({ $0.char! })
            print(arr)
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
                touchState = .listening
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
        touchState = .none
        prevCell = nil
        highlightedCells = []
    }
    
    fileprivate func cancelHighlight(){
        for cell in highlightedCells {
            cell.removeHighlight()
        }
        highlightedCells = []
    }
    
    fileprivate func updateHighlightForCell(_ cell: CharView) -> Bool{
        if highlightedCells.contains(cell){
            //going backwards, end touch, clear states
            cancelHighlight()
            return false
        }
        highlightedCells.append(cell)
        cell.updateHighlight()
        return true
    }
    
}

extension WordSearchView : UIGestureRecognizerDelegate {
    
}
