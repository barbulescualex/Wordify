//
//  CharCell.swift
//  Wordify
//
//  Created by Alex Barbulescu on 2019-05-13.
//  Copyright © 2019 ca.alexs. All rights reserved.
//

import UIKit

class CharCell: UIView, UIGestureRecognizerDelegate {
    //MARK: Vars
    ///character the cell holds
    public var char : Character? {
        didSet{
           updateChar()
        }
    }
    
    ///Font size of character in cell
    public var fontSize : CGFloat = 17 {
        didSet{
            UIView.transition(with: charLabel, duration: 0.4, options: .transitionCrossDissolve, animations: {
                 self.charLabel.font = UIFont.systemFont(ofSize: self.fontSize)
            })
        }
    }
    
    ///The position it is in the grid matrix (origin is in top left)
    var matrixPos = Point(x: 0, y: 0)
    
    ///Boolean flag to check if it is in a highlighted state
    private(set) var highlighted = false
    
    ///Boolean flag to indify that this cell was part of a valid and found string
    private(set) var solidified = false
    
    ///Colors to for different states
    private var solidifiedColor = UIColor.pink
    private var highlightColor = UIColor.green
    
    ///Flag set by Grid population algorithm to detect if the corresponding cell is part of a word
    public var isPartOfWord = false
    
    //Mark: View Components
    
    ///Label that holds the character
    private var charLabel : UILabel = {
        let label = UILabel()
        label.textColor = UIColor.gray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textAlignment = .center
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.minimumScaleFactor = 0.9
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    //MARK: Init
    required init(char: Character?){
        self.char = char
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
        layer.cornerRadius = 5
        clipsToBounds = false
        layer.borderWidth = 2
        layer.borderColor = UIColor.clear.cgColor
        
        //children
        addSubview(charLabel)
        updateChar()
        
        NSLayoutConstraint.activate([
            charLabel.topAnchor.constraint(equalTo: topAnchor),
            charLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            charLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            charLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            widthAnchor.constraint(equalTo: heightAnchor),
            heightAnchor.constraint(equalTo: widthAnchor)
        ])
    }
    
    //MARK: State Functions
    
    ///updates the char in the charLabel to the value the instance variable "char"
    fileprivate func updateChar(){
        if let char = char {
            charLabel.text = String(describing: char)
        } else {
            charLabel.text = nil
        }
        reset()
    }
    
    ///sets highlight state
    public func addHighlight(){
        UIView.animate(withDuration: 0.1) {
            self.charLabel.textColor = UIColor.white
            self.backgroundColor = self.highlightColor
        }
        highlighted = true
    }
    
    ///removes the highlight state
    public func removeHighlight(){
        if highlighted {
            UIView.animate(withDuration: 0.1) {
                self.charLabel.textColor = self.solidified ? UIColor.offWhite : UIColor.gray
                self.backgroundColor = self.solidified ? self.solidifiedColor : UIColor.clear
            }
            highlighted = false
        }
    }
    
    ///resets all state
    public func reset(){
        //clear state
        if !(solidified || highlighted) {return}
        UIView.animate(withDuration: 0.1) {
            self.charLabel.textColor = UIColor.gray
            self.backgroundColor =  UIColor.clear
        }
        solidified = false
        highlighted = false
    }
    
    ///sets cell soldify state
    public func solidify(){
        if solidified {
            removeHighlight()
            return
        }
        solidified = true
        UIView.animate(withDuration: 0.1) {
            self.charLabel.textColor = UIColor.white
            self.backgroundColor = self.solidifiedColor
        }
        highlighted = false
    }
    
    ///Flashes the cell to reveal itself as part of a word in the WordSearchView
    public func show(){
        UIView.animate(withDuration: 0.3, animations: {
            self.charLabel.textColor = UIColor.white
            self.backgroundColor = self.highlightColor.withAlphaComponent(0.5)
        }){_ in
            UIView.animate(withDuration: 0.2, animations: {
                self.charLabel.textColor = self.solidified ? UIColor.offWhite : UIColor.gray
                self.backgroundColor = self.solidified ? self.solidifiedColor : UIColor.clear
            })
        }
    }
}
