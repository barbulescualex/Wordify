//
//  CharCell.swift
//  Wordify
//
//  Created by Alex Barbulescu on 2019-05-13.
//  Copyright © 2019 ca.alexs. All rights reserved.
//

import UIKit

class CharCell: UIView, UIGestureRecognizerDelegate {
    var char : Character? {
        didSet{
           updateChar()
        }
    }
    
    var matrixPos : (Int, Int) = (0,0)
    
    var highlighted = false
    var transitioning = false
    
    private var charLabel : UILabel = {
        let label = UILabel()
        label.textColor = UIColor.gray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textAlignment = .center
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()
    
    required init(char: Character){
        self.char = char
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setup(){
        translatesAutoresizingMaskIntoConstraints = false
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
        
        layer.cornerRadius = 5
        clipsToBounds = false
        layer.borderWidth = 2
        layer.borderColor = UIColor.clear.cgColor
    }
    
    private func updateChar(){
        if let char = char {
            charLabel.text = String(describing: char)
        } else {
            charLabel.text = nil
        }
    }
    
    func updateHighlight(){
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
    
    func removeHighlight(){
        if highlighted {
            UIView.animate(withDuration: 0.1) {[weak self] in
                self?.charLabel.textColor = UIColor.gray
                self?.backgroundColor = UIColor.clear
            }
            highlighted = false
        }
    }
}
