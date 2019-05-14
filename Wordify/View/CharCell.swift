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
    var char : Character? {
        didSet{
           updateChar()
        }
    }
    
    ///the position it is in the grid matrix (origin is in top left)
    var matrixPos : (Int, Int) = (0,0)
    
    ///boolean flag to check if it is in a highlighted state
    var highlighted = false
    
    ///boolean flag to check that it's not currently transitioning between states
    var transitioning = false
    
    //Mark: View Components
    private var charLabel : UILabel = {
        let label = UILabel()
        label.textColor = UIColor.gray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textAlignment = .center
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()
    
    //MARK: Init
    required init(char: Character){
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
        
        //view properties
        layer.cornerRadius = 5
        clipsToBounds = false
        layer.borderWidth = 2
        layer.borderColor = UIColor.clear.cgColor
    }
    
    ///updates the char in the charLabel to the value the instance variable "char"
    fileprivate func updateChar(){
        if let char = char {
            charLabel.text = String(describing: char)
        } else {
            charLabel.text = nil
        }
    }
    
    ///flips the highlight state
    public func updateHighlight(){
        if transitioning { return }
        transitioning = true
        
        if highlighted {
            UIView.animate(withDuration: 0.1) {[weak self] in
                self?.charLabel.textColor = UIColor.gray
                self?.backgroundColor = UIColor.clear
            }
            highlighted = false
        } else {
            UIView.animate(withDuration: 0.1) {[weak self] in
                self?.charLabel.textColor = UIColor.white
                self?.backgroundColor = UIColor.highlight
            }
            highlighted = true
        }
        transitioning = false
    }
    
    ///removes the highlight state
    public func removeHighlight(){
        if highlighted {
            UIView.animate(withDuration: 0.1) {[weak self] in
                self?.charLabel.textColor = UIColor.gray
                self?.backgroundColor = UIColor.clear
            }
            highlighted = false
        }
    }
}
