//
//  WordSearchView.swift
//  Wordify
//
//  Created by Alex Barbulescu on 2019-05-13.
//  Copyright © 2019 ca.alexs. All rights reserved.
//

import UIKit

class WordSearchView: UIView, UIGestureRecognizerDelegate {
    var size : Int = 0
    
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
//            self.animateCellOut(cell)
        }

        for substack in stackContainer.subviews {
            substack.removeFromSuperview()
        }
        
        //populateChars()
    }
    
    func animateCellIn(_ cell: CharView){
        cell.alpha = 0
        cell.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(withDuration: 0.05, animations: {
            cell.transform = CGAffineTransform.identity
            cell.alpha = 1
        }) { (_) in
            
        }
    }
    
    func animateCellOut(_ cell: CharView){
        UIView.animate(withDuration: 0.05, animations: {
            cell.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            cell.alpha = 0
        }) { (_) in
            cell.removeFromSuperview()
        }
    }
    
    var prevCell : CharView?
    
    @objc func panned(_ sender: UIPanGestureRecognizer){
        let loc = sender.location(in: self)
        guard let cell = self.hitTest(loc, with: nil) as? CharView else {return}
        
        
        switch sender.state {
        case .began:
            print("began")
            cell.updateHighlight()
        case .changed:
            if cell != prevCell {
                cell.updateHighlight()
            }
        case .ended:
            print("ended")
            checkForWord()
        default:
            print("defualted in pan recognizer for WordSearchView")
        }
        
        prevCell = cell
    }
    
    fileprivate func checkForWord(){
        for cell in cellArray {
            cell.removeHighlight()
        }
    }
    
}
